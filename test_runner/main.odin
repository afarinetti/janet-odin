package main

import janet_engine "../janet_engine"
import janet_low "../janet_low"
import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Suites that cannot run inside the embedded VM, with one-line reasons.
// Seeded empirically: each fails or hangs when driven through the bindings,
// independent of host platform. (filewatch is handled separately in find_skip —
// it has no macOS backend but passes on Linux CI.)
IncompatibleSuite :: struct {
	path:   string,
	reason: string,
}

INCOMPATIBLE_SUITES: []IncompatibleSuite = {
	{
		"vendor/janet/test/suite-bundle.janet",
		"needs jpm/bundle module-installation infrastructure unavailable in a fresh checkout",
	},
	{
		"vendor/janet/test/suite-ev.janet",
		"spawns the standalone janet binary via os/spawn; the embedded VM has no `janet` executable",
	},
	{
		"vendor/janet/test/suite-os.janet",
		"spawns the standalone janet binary via os/execute; the embedded VM has no `janet` executable",
	},
	{
		"vendor/janet/test/suite-boot.janet",
		"asserts call-frame identity (curenv, eval-context) that only hold when loaded as the root script",
	},
}

// Exit code captured from the overridden os/exit. -1 = os/exit was not called.
g_exit_code: i32 = -1

// suite_exit overrides Janet's os/exit so a failing suite cannot terminate the
// whole runner process (janet_pcall cannot intercept a real C exit). It records
// the requested code into g_exit_code and returns nil, letting execution unwind.
suite_exit :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	if argc >= 1 {
		g_exit_code = janet_low.janet_get_integer(argv, 0)
	} else {
		g_exit_code = 0
	}
	return janet_low.janet_wrap_nil()
}

main :: proc() {
	eng, ok := janet_engine.janet_engine_init({})
	if !ok {
		fmt.eprintln("FATAL: janet_engine_init failed")
		os.exit(1)
	}
	defer janet_engine.janet_engine_deinit(eng)

	// Env setup guard for helper.janet:4 (`(put root-env *lint-warn* :strict)`).
	// Harmless no-op: root-env and *lint-warn* are both bound in core_env
	// (corelib.c:1332 and boot.janet:180). Kept as a defensive precaution.
	{
		out: janet_low.Janet
		guard :=
			"(do" +
			" (when (nil? root-env) (put (curenv) 'root-env (curenv)))" +
			" (when (nil? *lint-warn*) (var *lint-warn* nil)))"
		_ = janet_low.janet_dostring(eng.env, transmute(cstring)mem.raw_data(guard), "setup", &out)
	}

	// Override os/exit directly in the env via janet_def (the same mechanism that
	// registered it as JANET_CORE_REG("os/exit")). There is no `os/` table to put into.
	if !janet_engine.janet_register(eng, "os/exit", suite_exit) {
		fmt.eprintln("FATAL: could not override os/exit")
		os.exit(1)
	}

	// Load helper once so its test-counter vars exist in env. Each suite's own
	// `(import ./helper ...)` reuses the cached module. We reset the counters
	// per suite (see run_suite) because all suites share one process/env, unlike
	// Janet's own runner which uses a fresh process per suite.
	{
		out: janet_low.Janet
		setup :=
			"(setdyn :current-file \"vendor/janet/test/suite-array.janet\")" +
			" (import ./helper :prefix \"\" :exit true)"
		status := janet_low.janet_dostring(
			eng.env,
			transmute(cstring)mem.raw_data(setup),
			"setup",
			&out,
		)
		if status != 0 || g_exit_code == 1 {
			fmt.eprintf(
				"FATAL: could not load test helper (status=%d exit=%d)\n",
				status,
				g_exit_code,
			)
			os.exit(1)
		}
	}

	suites, examples := discover()
	defer delete(suites)
	defer delete(examples)

	suite_pass, suite_fail, suite_skip := 0, 0, 0
	ex_ok, ex_fail := 0, 0

	fmt.println("--- Janet suites (run through the janet-odin bindings) ---")
	for suite_path in suites {
		name := filepath.base(suite_path)
		if found, reason := find_skip(suite_path); found {
			fmt.printf("SKIP %s (%s)\n", name, reason)
			suite_skip += 1
			continue
		}
		ok, msg := run_suite(eng, suite_path)
		if ok {
			fmt.printf("PASS %s\n", name)
			suite_pass += 1
		} else {
			fmt.printf("FAIL %s — %s\n", name, msg)
			suite_fail += 1
		}
	}

	fmt.println("\n--- Janet examples (compile-checked through the bindings) ---")
	for ex_path in examples {
		name := filepath.base(ex_path)
		ok, msg := compile_check(eng, ex_path)
		if ok {
			fmt.printf("OK   %s\n", name)
			ex_ok += 1
		} else {
			fmt.printf("FAIL %s — %s\n", name, msg)
			ex_fail += 1
		}
	}

	fmt.println()
	fmt.printf("Suites: %d passed, %d failed, %d skipped\n", suite_pass, suite_fail, suite_skip)
	fmt.printf("Examples compile-checked: %d ok, %d failed\n", ex_ok, ex_fail)

	if suite_fail > 0 || ex_fail > 0 {
		os.exit(1)
	}
}

find_skip :: proc(path: string) -> (found: bool, reason: string) {
	for s in INCOMPATIBLE_SUITES {
		if s.path == path do return true, s.reason
	}
	// filewatch has backends only for Linux (inotify) and Windows; macOS has none,
	// so it panics locally. On Linux CI the inotify backend is compiled and it passes.
	when ODIN_OS == .Darwin {
		if path == "vendor/janet/test/suite-filewatch.janet" {
			return true, "filewatch has no backend on macOS (inotify is Linux-only)"
		}
	}
	return false, ""
}

// run_suite evaluates a suite file through the bindings. Each suite runs in a
// FRESH child env (parent = root-env), mirroring Janet's own runner which uses a
// fresh process per suite. This isolates per-suite state and lets suites assert
// (curenv 1) == root-env. janet_dobytes does NOT set :current-file (run.c:31), so
// we prepend a (setdyn :current-file ...) so the suite's `(import ./helper ...)`
// resolves and error messages cite the path.
run_suite :: proc(eng: ^janet_engine.JanetEngine, suite_path: string) -> (ok: bool, msg: string) {
	data, err := os.read_entire_file_from_path(suite_path, context.allocator)
	if err != nil {
		return false, "could not read file"
	}
	defer delete(data)

	// Reset helper's test counters. The counter vars live in the cached helper
	// module, so their refs are shared across suites and accumulate without this.
	{
		rout: janet_low.Janet
		reset := "(set num-tests-run 0) (set num-tests-passed 0) (set skip-count 0) (set skip-n 0)"
		_ = janet_low.janet_dostring(
			eng.env,
			transmute(cstring)mem.raw_data(reset),
			"reset",
			&rout,
		)
	}

	// Fresh child env (parent = root-env), GC-rooted for the duration of the suite.
	child_env := make_child_env(eng)
	if child_env == nil {
		return false, "could not create child environment"
	}
	child_val := janet_low.janet_wrap_table(child_env)
	janet_low.janet_gcroot(child_val)
	defer janet_low.janet_gcunroot(child_val)

	source: [dynamic]u8
	defer delete(source)
	header := fmt.tprintf("(setdyn :current-file \"%s\")\n", suite_path)
	append(&source, ..transmute([]u8)header)
	append(&source, ..data)

	g_exit_code = -1
	out: janet_low.Janet
	cpath := strings.clone_to_cstring(suite_path, context.allocator)
	defer delete(cpath)
	status := janet_low.janet_dobytes(child_env, &source[0], i32(len(source)), cpath, &out)

	if g_exit_code == 1 {
		return false, "end-suite reported assertion failures"
	}
	if status != 0 {
		return false, fmt.tprintf("eval error (errflags=%d)", status)
	}
	return true, ""
}

// make_child_env returns a fresh table with root-env as prototype ((make-env)),
// so a suite runs isolated like a standalone script whose parent env is root-env.
make_child_env :: proc(eng: ^janet_engine.JanetEngine) -> ^janet_low.JanetTable {
	out: janet_low.Janet
	_ = janet_low.janet_dostring(eng.env, "(make-env)", "env", &out)
	return janet_low.janet_unwrap_table(out)
}

// compile_check parses and compiles an example WITHOUT executing it (the janet
// `-k` equivalent), so IO/network examples like tcpserver.janet cannot hang.
compile_check :: proc(eng: ^janet_engine.JanetEngine, ex_path: string) -> (ok: bool, msg: string) {
	data, err := os.read_entire_file_from_path(ex_path, context.allocator)
	if err != nil {
		return false, "could not read file"
	}
	defer delete(data)

	parser: janet_low.JanetParser
	janet_low.janet_parser_init(&parser)
	defer janet_low.janet_parser_deinit(&parser)

	for b in data {
		janet_low.janet_parser_consume(&parser, b)
		// status == 1 == JANET_PARSE_ERROR
		if janet_low.janet_parser_status(&parser) == 1 {
			return false, fmt.tprintf("parse error: %s", janet_low.janet_parser_error(&parser))
		}
	}
	janet_low.janet_parser_eof(&parser)
	if janet_low.janet_parser_status(&parser) == 1 {
		return false, fmt.tprintf("parse error: %s", janet_low.janet_parser_error(&parser))
	}

	cpath := strings.clone_to_cstring(ex_path, context.allocator)
	defer delete(cpath)
	src_name := janet_low.janet_cstring(cpath) // JanetString; GC-managed

	for janet_low.janet_parser_has_more(&parser) {
		form := janet_low.janet_parser_produce(&parser)
		cres := janet_low.janet_compile(form, eng.env, src_name)
		if cres.status != .OK {
			// Janet strings are null-terminated, safe to view as cstring.
			return false, fmt.tprintf("compile error: %s", transmute(cstring)cres.error)
		}
	}
	return true, ""
}
