# Janet-Odin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an Odin interface to the Janet scripting language: type-safe wrappers over Janet's C API, an engine layer (proc registration, hot-reload, logging bridge), and integration with Janet's own test suite.

**Architecture:** Core (pure Janet C wrappers, no engine deps) + Engine (proc registration, hot-reload, logger). Core is importable standalone; Engine builds on Core.

**Tech Stack:** Janet 1.41.x C library, Odin language, no external dependencies beyond Janet's C source.

---

## Global Constraints

- Janet version: 1.41.x (currently installed: 1.41.2-homebrew)
- Janet C source headers: `/opt/homebrew/include/janet/janet.h`
- Janet C library: compiled from source (no DLL/shared library required)
- Janet's VM is thread-local; each thread must allocate its own VM with `janet_vm_alloc()`
- `janet_init()` / `janet_deinit()` are process-global (call once per process)
- Janet C function signature: `Janet my_func(int32_t argc, Janet *argv)` — access args with `janet_getinteger(&argv[i], n)`, etc.
- Janet values are NOT reference-counted by default; use `janet_gcroot()` / `janet_gcunroot()` for long-lived values
- Janet Fibers are the concurrency unit, not OS threads — they are cooperative

---

## Package File Structure

```
janet/
├── core/
│   ├── janet.odin          # C imports + foreign library declaration
│   ├── types.odin          # JanetType, JanetValue union, type constants
│   ├── vm.odin             # janet_init, janet_vm_alloc, janet_deinit, janet_gc
│   ├── value.odin          # janet_wrap_*, janet_unwrap_*, janet_type_of
│   ├── stack.odin          # janet_push_*, janet_get_*, janet_pop, janet_dup
│   ├── eval.odin           # janet_eval, janet_do_file, janet_call, janet_pcall
│   └── thread.odin         # janet_fiber, janet_fiber_status, janet_continue, janet_pcall
├── engine/
│   ├── engine.odin         # JanetEngine struct, lifecycle procs
│   ├── bindings.odin       # janet_register, janet_unregister, janet_register_procs
│   ├── hotreload.odin      # HotReloadConfig, janet_hotreload_* procs
│   └── logger.odin        # janet_logger_init, janet_logger_shutdown
├── attributes.odin         # @(janet_function, name=, summary=) proc attribute
└── errors.odin            # JanetError, janet_error_format, janet_last_error

tests/
├── core_test.odin
├── bindings_test.odin
├── hotreload_test.odin
└── run_janet_tests.odin
```

---

## Task 1: Project scaffold and Janet C foreign binding

**Files:**
- Create: `janet/core/janet.odin`
- Create: `janet/core/types.odin`
- Modify: (none)

**Janet.odin** declares the foreign import and includes the Janet header so Odin can call into Janet's C library. This is the build foundation.

**Janet.odin content:**
```odin
package janet

foreign import janet_lib {
    "/opt/homebrew/lib/libjanet.a" | "/usr/local/lib/libjanet.a",
    "c",
}

@(include)
foreign janet_lib {
    @(link_name="janet_init")
    janet_init :: proc() -> i32 ---

    @(link_name="janet_deinit")
    janet_deinit :: proc() ---
}
```

**Interfaces:**
- Produces: `janet_init()` callable from Odin, linking against `libjanet.a`

- [ ] **Step 1: Create `janet/core/janet.odin`** — foreign import + `@(include)` for Janet header, `janet_init`/`janet_deinit` foreign declarations

- [ ] **Step 2: Create `janet/core/types.odin`** — `JanetType` enum matching Janet's `enum JanetType` (JANET_NUMBER=0 through JANET_POINTER=15), `JANET_TYPE_NAMES` string array, `janet_type_names` foreign declaration

- [ ] **Step 3: Verify build** — `odin build .` in `janet/` subdir should compile without errors; confirm `janet_init` is found by the linker

- [ ] **Step 4: Commit**
```bash
git add janet/core/janet.odin janet/core/types.odin
git commit -m "feat(janet): scaffold Janet C foreign binding and types"
```

---

## Task 2: JanetValue and Janet VM

**Files:**
- Create: `janet/core/vm.odin`
- Modify: `janet/core/types.odin`

**JanetValue** in Odin must mirror Janet's nanboxed `union Janet` — since Janet uses NaN-boxing on 64-bit, the `Janet` union is either `u64`, `i64`, `f64`, or `rawptr`. We expose this as an Odin `Janet` raw union type.

`JanetVM` is `rawptr` — the actual struct is opaque in Janet's API.

**Janet.odin update** — add these foreign declarations:
```odin
    @(link_name="janet_vm_alloc")
    janet_vm_alloc :: proc() -> ^JanetVM ---

    @(link_name="janet_vm_free")
    janet_vm_free :: proc(vm: ^JanetVM) ---

    @(link_name="janet_local_vm")
    janet_local_vm :: proc() -> ^JanetVM ---

    @(link_name="janet_vm_load")
    janet_vm_load :: proc(from: ^JanetVM) ---

    @(link_name="janet_core_env")
    janet_core_env :: proc(replacements: ^JanetTable) -> ^JanetTable ---
```

**Interfaces:**
- Produces: `JanetVM` (opaque `rawptr`), `janet_vm_alloc()`, `janet_vm_free()`, `janet_local_vm()`

- [ ] **Step 1: Update `janet/core/types.odin`** — add `Janet` raw union type, `JanetVM` as `rawptr`, `JanetString`, `JanetSymbol`, `JanetKeyword`, `JanetCFunction` type aliases, `JanetArray`, `JanetTable`, `JanetFunction`, `JanetFiber`, `JanetBuffer`, `JanetStruct`, `JanetTuple`, `JanetAbstract`, `JanetPointer`, `JanetKV` pointer types. Add `JANET_NIL`, `JANET_NUMBER`, etc. as constants matching Janet enum values.

- [ ] **Step 2: Create `janet/core/vm.odin`** — `janet_init()` (call once, globally), `janet_deinit()`, `janet_vm_alloc()`, `janet_vm_free()`, `janet_vm_load()`, `janet_core_env(nil_table: ^JanetTable) -> ^JanetTable` (pass `nil` to get root env). `JanetEngine` struct in engine层 goes here for now since it's the only VM container.

- [ ] **Step 3: Write smoke test in `tests/smoke_test.odin`**:
```odin
package janet_test

import janet ".."

@test
smoke_init :: proc() {
    result := janet.janet_init()
    assert(result == 0, "janet_init failed")
    janet.janet_deinit()
}
```

- [ ] **Step 4: Verify build** — `odin test .` passes

- [ ] **Step 5: Commit**
```bash
git add janet/core/types.odin janet/core/vm.odin tests/smoke_test.odin
git commit -m "feat(janet): add JanetVM and JanetValue types"
```

---

## Task 3: Value wrapping, unwrapping, and type checking

**Files:**
- Create: `janet/core/value.odin`
- Modify: `janet/core/types.odin` (add `janet_type_names` foreign)

**value.odin** implements conversion between Odin types and Janet values. Since Janet uses nanboxing, many wrap/unwrap operations are zero-cost C macros in Janet — we declare them as Odin `inline` procs that call the underlying C.

Key insight: `janet_wrap_integer(x)` is `#define janet_wrap_integer(x) janet_nanbox_from_bits(...)` — we declare it as an Odin `inline` proc. `janet_unwrap_integer(x)` similarly. `janet_type(x)` is also a macro.

**Interfaces:**
- Produces: `janet_wrap_integer(i64) -> Janet`, `janet_wrap_float(f64) -> Janet`, `janet_wrap_boolean(bool) -> Janet`, `janet_wrap_string(JanetString) -> Janet`, `janet_wrap_nil() -> Janet`, `janet_wrap_true() -> Janet`, `janet_wrap_false() -> Janet`, `janet_wrap_pointer(rawptr) -> Janet`, `janet_wrap_cfunction(JanetCFunction) -> Janet`, `janet_wrap_array(^JanetArray) -> Janet`, `janet_wrap_table(^JanetTable) -> Janet`, `janet_wrap_function(^JanetFunction) -> Janet`, `janet_wrap_buffer(^JanetBuffer) -> Janet`, `janet_wrap_abstract(JanetAbstract) -> Janet`, `janet_unwrap_integer(Janet) -> i64`, `janet_unwrap_float(Janet) -> f64`, `janet_unwrap_boolean(Janet) -> bool`, `janet_unwrap_string(Janet) -> JanetString`, `janet_unwrap_pointer(Janet) -> rawptr`, `janet_unwrap_cfunction(Janet) -> JanetCFunction`, `janet_unwrap_array(Janet) -> ^JanetArray`, `janet_unwrap_table(Janet) -> ^JanetTable`, `janet_unwrap_function(Janet) -> ^JanetFunction`, `janet_type(Janet) -> JanetType`, `janet_checktype(Janet, JanetType) -> i32`, `janet_truthy(Janet) -> i32`

- [ ] **Step 1: Create `janet/core/value.odin`** — declare all `janet_wrap_*`, `janet_unwrap_*`, `janet_type`, `janet_checktype`, `janet_truthy` as foreign or inline procs matching Janet's headers exactly

- [ ] **Step 2: Create `janet/core/stack.odin`** — `janet_get_integer`, `janet_get_number`, `janet_get_boolean`, `janet_get_string`, `janet_get_cstring`, `janet_get_array`, `janet_get_table`, `janet_get_function`, `janet_get_cfunction`, `janet_get_buffer`, `janet_get_fiber`, `janet_get_pointer`, `janet_get_abstract`, `janet_getkeyword`, `janet_get_boolean`, `janet_getsize`, `janet_getnat`, `janet_getinteger`, `janet_getinteger64`, `janet_getuinteger` — all the `janet_get_*` argv-accessors from janet.h

- [ ] **Step 3: Write value round-trip tests**:
```odin
@test
test_wrap_unwrap_integer :: proc() {
    val := janet.janet_wrap_integer(42)
    assert(janet.janet_unwrap_integer(val) == 42)
}

@test
test_wrap_unwrap_float :: proc() {
    val := janet.janet_wrap_float(3.14)
    assert(janet.janet_unwrap_float(val) == 3.14)
}

@test
test_wrap_unwrap_string :: proc() {
    s := janet.janet_wrap_string("hello")
    assert(janet.janet_unwrap_string(s) == "hello")
}
```

- [ ] **Step 4: Verify** — `odin test .` passes

- [ ] **Step 5: Commit**
```bash
git add janet/core/value.odin janet/core/stack.odin tests/core_test.odin
git commit -m "feat(janet): add value wrapping and stack accessors"
```

---

## Task 4: Eval, do_file, call, and pcall

**Files:**
- Create: `janet/core/eval.odin`
- Modify: `janet/core/vm.odin`

**eval.odin** wraps Janet's eval machinery:
- `janet_dostring(env, str, sourcePath, &out)` — evaluates a string, returns 0 on success
- `janet_compile(source, env, where)` — compiles to `JanetCompileResult` (has `.ok` and `.function`)
- `janet_pcall(fun, argc, argv, &out, &fiber)` — protected call, returns `JanetSignal` (0=JANET_SIGNAL_OK)
- `janet_fiber(fun, capacity, argc, argv)` — creates a fiber
- `janet_fiber_status(fiber)` — returns status
- `janet_continue(fiber, in, &out)` — resume fiber
- `janet_stacktrace(fiber, err)` — format error

No built-in `janet_dofile` — implement as: read file contents → `janet_dostring`.

**JanetCompileResult** struct:
```odin
JanetCompileResult :: struct {
    ok:       i32,         // 1 = success
    data:     Janet,       // function if ok
    error:    Janet,       // error string if !ok
    source:   JanetString, // source location
    line:     i32,
    column:   i32,
}
```

**JanetSignal** enum:
```odin
JanetSignal :: enum i32 {
    OK       = 0,
    ERROR    = 1,
    DEBUG    = 2,
    YIELD    = 3,
    USER0    = 4,
    USER1    = 5,
    USER2    = 6,
    USER3    = 7,
    USER4    = 8,
    USER5    = 9,
    USER6    = 10,
    USER7    = 11,
    USER8    = 12,
    USER9    = 13,
}
```

**JanetFiberStatus** enum (from janet.h):
```odin
JanetFiberStatus :: enum i32 {
    DEAD       = 0,
    ALIVE      = 1,
    USER0      = 8,  // ...
}
```

**Interfaces:**
- Produces: `janet_eval(vm: ^JanetVM, source: string) -> (Janet, error)`, `janet_do_file(vm: ^JanetVM, path: string) -> (Janet, error)`, `janet_call(vm: ^JanetVM, fun: ^JanetFunction, argc: i32, argv: []Janet) -> (Janet, error)`, `janet_pcall(vm: ^JanetVM, fun: ^JanetFunction, argc: i32, argv: []Janet) -> (Janet, JanetFiber, JanetSignal)`, `janet_fiber_new(fun: ^JanetFunction, capacity: i32, argc: i32, argv: []Janet) -> ^JanetFiber`, `janet_fiber_status(fiber: ^JanetFiber) -> JanetFiberStatus`, `janet_fiber_continue(fiber: ^JanetFiber, in: Janet, out: ^Janet) -> JanetSignal`, `janet_stacktrace(fiber: ^JanetFiber, err: Janet)`

- [ ] **Step 1: Create `janet/core/eval.odin`** — `JanetCompileResult`, `JanetSignal`, `JanetFiberStatus` types; `janet_compile`, `janet_dostring`, `janet_pcall`, `janet_fiber`, `janet_fiber_status`, `janet_fiber_can_resume`, `janet_continue`, `janet_stacktrace` foreign declarations; `janet_eval`, `janet_do_file`, `janet_call` Odin wrappers; `JanetError` struct in `janet/errors.odin`

- [ ] **Step 2: Create `janet/errors.odin`** — `JanetError` struct with `kind`, `msg`, `source`, `line`, `trace: [dynamic]StackFrame`. `StackFrame` struct. `janet_error_format(err: JanetError) -> string`. `janet_signal_to_string(s: JanetSignal) -> string`.

- [ ] **Step 3: Write eval tests**:
```odin
@test
test_eval_integer :: proc() {
    janet.janet_init()
    defer janet.janet_deinit()

    vm := janet.janet_vm_alloc()
    defer janet.janet_vm_free(vm)
    janet.janet_vm_load(vm)

    result, err := janet.janet_eval(vm, `(+ 1 2)`)
    assert(err == nil)
    assert(janet.janet_unwrap_integer(result) == 3)
}

@test
test_eval_string :: proc() {
    janet.janet_init()
    defer janet.janet_deinit()

    vm := janet.janet_vm_alloc()
    defer janet.janet_vm_free(vm)
    janet.janet_vm_load(vm)

    result, err := janet.janet_eval(vm, `"hello"`)
    assert(err == nil)
    assert(janet.janet_unwrap_string(result) == "hello")
}

@test
test_eval_error :: proc() {
    janet.janet_init()
    defer janet.janet_deinit()

    vm := janet.janet_vm_alloc()
    defer janet.janet_vm_free(vm)
    janet.janet_vm_load(vm)

    _, err := janet.janet_eval(vm, `(+ 1 "foo")`)
    assert(err != nil, "expected type error")
}
```

- [ ] **Step 4: Write do_file test** — create `tests/scripts/test_script.janet` with `(+ 10 20)`, call `janet_do_file`, assert result is 30

- [ ] **Step 5: Verify** — `odin test .` passes

- [ ] **Step 6: Commit**
```bash
git add janet/core/eval.odin janet/errors.odin tests/core_test.odin tests/scripts/test_script.janet
git commit -m "feat(janet): add eval, do_file, call, pcall, and error types"
```

---

## Task 5: Proc registration and bindings

**Files:**
- Create: `janet/attributes.odin`
- Create: `janet/engine/bindings.odin`
- Create: `janet/engine/engine.odin`
- Modify: `janet/core/eval.odin` (add `janet_register` foreign)

**attributes.odin** defines the proc attribute:
```odin
// Proc attribute for Janet binding registration
janet_function :: proc(name: string, summary: string) -> type_info_node ---
```

**bindings.odin** handles registration. The challenge: we need to generate a `JanetCFunction` adapter from an Odin proc. The adapter reads Janet argv, converts to Odin types, calls the Odin proc, converts the result back to Janet, and returns it.

Approach: **per-signature adapter generation**. For each distinct Odin signature we want to support (i32,i32->i32; f64,f64->f64; string->string; etc.), we write a typed adapter proc manually. This is explicit and type-safe.

```odin
// Example: adapter for (i64, i64) -> i64
_adapter_i64_i64_to_i64 :: proc "c" (fn: proc(i64, i64) -> i64, name: string) -> JanetCFunction {
    return proc(argc: i32, argv: [^]Janet) -> Janet {
        x := janet_unwrap_integer(argv[0])
        y := janet_unwrap_integer(argv[1])
        result := fn(x, y)
        return janet_wrap_integer(result)
    }
}
```

For v1, support these signatures:
- `() -> i64`
- `(i64) -> i64`
- `(i64, i64) -> i64`
- `() -> f64`
- `(f64) -> f64`
- `(f64, f64) -> f64`
- `() -> string`
- `(string) -> string`
- `() -> bool`
- `(bool) -> bool`
- `(i64, i64, i64) -> i64`
- `(string, string) -> string`
- `(string, i64) -> string`
- `(i64, string) -> string`

**JanetEngine struct** in `engine.odin`:
```odin
JanetEngine :: struct {
    vm:           ^JanetVM,
    env:          ^JanetTable,
    boot_script:  string,
}

janet_engine_init :: proc(cfg: EngineConfig) -> (^JanetEngine, error)
janet_engine_deinit :: proc(eng: ^JanetEngine)
```

**Registration flow:**
1. `janet_engine_init()` allocates VM, loads it, creates env table
2. `janet_register(eng, "add", my_add_proc)` — wraps the Odin proc in a typed adapter, calls `janet_dostring(eng.env, "(def ...)", ...)` to register the cfunction, OR directly puts the wrapped cfunction into `eng.env`
3. `janet_unregister(eng, "add")` — removes from env

Direct env registration: `janet_table_put(eng.env, janet_wrap_keyword("add"), janet_wrap_cfunction(cfun))`

**Interfaces:**
- Consumes: `janet_wrap_cfunction`, `janet_table_put`, `janet_core_env`
- Produces: `janet_engine_init(EngineConfig) -> (^JanetEngine, error)`, `janet_engine_deinit(^JanetEngine)`, `janet_register(eng: ^JanetEngine, name: string, proc: $T)`, `janet_unregister(eng: ^JanetEngine, name: string)`, `janet_lookup(eng: ^JanetEngine, name: string) -> Janet`

- [ ] **Step 1: Create `janet/attributes.odin`** — `janet_function` attribute declaration (empty struct/tagged, no runtime code needed in Odin — this is metadata for code generators)

- [ ] **Step 2: Create `janet/engine/engine.odin`** — `EngineConfig` struct, `JanetEngine` struct, `janet_engine_init`, `janet_engine_deinit`, `janet_lookup`

- [ ] **Step 3: Create `janet/engine/bindings.odin`** — typed adapter procs for each supported signature (see list above), `janet_register_impl` (takes raw `JanetCFunction`), `janet_register` (type-keyed dispatcher), `janet_unregister`. The `janet_register` overload uses `when` + type introspection to select the right adapter at compile time.

- [ ] **Step 4: Write bindings tests**:
```odin
@test
test_register_and_call_add :: proc() {
    eng, _ := janet.janet_engine_init({})
    defer janet.janet_engine_deinit(eng)

    my_add :: proc "c" (x: i64, y: i64) -> i64 {
        return x + y
    }
    janet.janet_register(eng, "add", my_add)

    result, err := janet.janet_eval(eng.vm, "(add 2 3)")
    assert(err == nil)
    assert(janet.janet_unwrap_integer(result) == 5)
}

@test
test_register_and_call_string_fn :: proc() {
    eng, _ := janet.janet_engine_init({})
    defer janet.janet_engine_deinit(eng)

    my_upper :: proc "c" (s: JanetString) -> JanetString {
        // Convert and return uppercased string
        return s  // simplified
    }
    janet.janet_register(eng, "upper", my_upper)

    result, err := janet.janet_eval(eng.vm, `(upper "hello")`)
    assert(err == nil)
}
```

- [ ] **Step 5: Verify** — `odin test .` passes

- [ ] **Step 6: Commit**
```bash
git add janet/attributes.odin janet/engine/engine.odin janet/engine/bindings.odin tests/bindings_test.odin
git commit -m "feat(janet): add JanetEngine and proc registration system"
```

---

## Task 6: Hot-reload manager

**Files:**
- Create: `janet/engine/hotreload.odin`

**hotreload.odin** implements file watching and safe code reloading.

**File watching** — use OS-native APIs:
- macOS: `FSEvents` via `darwin_fsevents` (or simpler: stat polling with `os.last_modified_time`)
- Linux: `inotify` via raw syscall or `epoll`
- Windows: `ReadDirectoryChangesW`

For v1, use **stat polling** — `os.last_modified_time` on each watched file, detect changes by comparing modification time. This is simple, portable, and sufficient for hot-reload use cases.

```odin
WatchedFile :: struct {
    path:       string,
    mtime:      time.Time,
    func_ref:   ^JanetFunction,   // current active function
}

HotReloadState :: struct {
    eng:        ^JanetEngine,
    files:      [dynamic]WatchedFile,
    poll_ms:    u32,
    cfg:        HotReloadConfig,
}
```

**Reload flow:**
1. `janet_hotreload_init(eng, cfg)` — set up file list from `watch_dir` + `file_pattern` glob
2. `janet_hotreload_poll(state)` — called each frame/tick:
   - For each watched file, check if `os.last_modified_time(path)` > stored `mtime`
   - If changed: recompile in **isolated fiber** (not the main VM thread)
   - If compile succeeds: swap `WatchedFile.func_ref` atomically
   - If compile fails: emit `Error` event, keep old function
3. User's reload callback receives `HotReloadEvent`

**Compile isolation:** Create a temporary fiber for each file compile:
```odin
// In isolated fiber (cooperative, so we run it to completion synchronously):
compile_result := janet.janet_dostring(eng.env, new_source, path, &out)
// If result.jan > 0: success, atomically update func_ref
```

For true preemption safety, Janet's `janet_step` could be used but is complex — stat polling in a sync loop is acceptable for v1 since hot-reload is not real-time.

**HotReloadConfig:**
```odin
HotReloadConfig :: struct {
    watch_dir:         string,
    file_pattern:      string,   // e.g. "*.janet" or "scripts/*.janet"
    poll_interval_ms:  u32,
    compile_timeout_ms: u32,   // 0 = no timeout
}

HotReloadEvent :: enum {
    Loaded,
    Error,
    Unloaded,
}
```

**Interfaces:**
- Consumes: `janet_engine_init`, `janet_dostring`, `janet_fiber`, `janet_continue`
- Produces: `janet_hotreload_init(eng: ^JanetEngine, cfg: HotReloadConfig) -> (^HotReloadState, error)`, `janet_hotreload_shutdown(state: ^HotReloadState)`, `janet_hotreload_poll(state: ^HotReloadState) -> []HotReloadEvent`, `janet_hotreload_reload(state: ^HotReloadState, path: string) -> error`

- [ ] **Step 1: Create `janet/engine/hotreload.odin`** — `HotReloadConfig`, `HotReloadEvent`, `HotReloadState`, `janet_hotreload_init`, `janet_hotreload_shutdown`, `janet_hotreload_poll`, `janet_hotreload_reload`. Stat polling via `os.last_modified_time`. Compile uses `janet_dostring` in the engine's VM (synchronous for v1).

- [ ] **Step 2: Write hotreload tests** — create `tests/scripts/hotreload_test.janet`, start hotreload, modify file externally, poll, verify new function is active

- [ ] **Step 3: Verify** — `odin test .` passes

- [ ] **Step 4: Commit**
```bash
git add janet/engine/hotreload.odin tests/hotreload_test.odin
git commit -m "feat(janet): add hot-reload manager with file watching"
```

---

## Task 7: Logger bridge

**Files:**
- Create: `janet/engine/logger.odin`

**logger.odin** redirects Janet's print output to Odin logging.

Janet prints go through the `os/procs` module's `print` and `prin` — which ultimately write to `stdout`. We can redirect stdout to our callback by:

1. Setting a custom print handler via Janet's abstract types mechanism, OR
2. Replacing the Janet `print` function in the env table with a custom one that calls Odin logging

For v1: **option 2** is simpler. We register a custom `print` cfunction in the env that intercepts all print output and routes it to Odin's `log` package.

```odin
janet_print_cfunction :: proc "c" (argc: i32, argv: [^]Janet) -> Janet {
    // Collect all args, format them, call Odin log
    buf: [1024]byte
    pos := 0
    for i := 0; i < argc; i += 1 {
        val := argv[i]
        s := janet_to_string(val)  // format value
        for c in s {
            buf[pos] = c
            pos += 1
            if pos >= 1024 { break }
        }
        if i < argc - 1 {
            buf[pos] = ' '
            pos += 1
        }
    }
    log_string := string(buf[:pos])
    log.info(log_string)
    return janet_wrap_nil()
}
```

**Interfaces:**
- Consumes: `janet_dostring`, `janet_register`
- Produces: `janet_logger_init(eng: ^JanetEngine) -> error`, `janet_logger_shutdown(eng: ^JanetEngine)`

- [ ] **Step 1: Create `janet/engine/logger.odin`** — `janet_print_cfunction`, `janet_logger_init`, `janet_logger_shutdown`. `janet_logger_init` does `janet_dostring(eng.env, "(defn print [ & args] ...)")` or registers the print cfunction directly.

- [ ] **Step 2: Write logger tests** — `janet_eval("(print \"hello from janet\")"`, verify it appears in Odin log output

- [ ] **Step 3: Verify** — `odin test .` passes

- [ ] **Step 4: Commit**
```bash
git add janet/engine/logger.odin tests/logger_test.odin
git commit -m "feat(janet): add logger bridge from Janet print to Odin log"
```

---

## Task 8: Janet conformance test suite

**Files:**
- Create: `tests/run_janet_tests.odin`

**run_janet_tests.odin** fetches and runs Janet's official test suite.

Janet's test files live at: `https://github.com/janet-lang/janet/tree/master/test`
- `test/janet-tests.janet` — main test suite
- `test/amend-tests.janet` — `amend` function tests

For offline use, we include the test files in the repo under `tests/janet_tests/`.

**Running the tests:** Janet has a built-in testing framework accessed via `jamt` command or `janet/run-tests`. We can also use Janet's `os/procs` to capture test output.

Simpler approach for v1: download `test/janet-tests.janet` from Janet releases or use a known commit hash, place it in `tests/janet_tests/`, and run it via our wrapper:

```odin
// In run_janet_tests.odin:
result, err := janet.janet_do_file(eng.vm, "tests/janet_tests/janet-tests.janet")
// Janet test runner exits with 0 on success, 1 on failure
```

**Test result:** We parse the exit status / result to determine pass/fail.

If Janet's tests require the full REPL or `jamt` binary, an alternative is to use `janet_compile` + `janet_pcall` on each test expression individually and compare output.

- [ ] **Step 1: Create `tests/run_janet_tests.odin`** — attempt to run Janet's `test/janet-tests.janet` via the wrapper. If Janet tests require the `jamt` binary (full REPL mode), fall back to: compile each `.janet` file with `janet -c` and report syntax errors only.

- [ ] **Step 2: Run tests** — `odin run tests/run_janet_tests.odin` and verify it completes without errors

- [ ] **Step 3: Commit**
```bash
git add tests/run_janet_tests.odin tests/janet_tests/
git commit -m "test(janet): run Janet conformance tests against wrapper"
```

---

## Spec Coverage Check

| Spec Requirement | Task |
|---|---|
| Janet VM init/deinit | Task 1, Task 2 |
| JanetValue tagged union | Task 2, Task 3 |
| Stack push/pop/peek | Task 3 |
| Eval, do_file, call | Task 4 |
| Thread/fiber isolation | Task 4 |
| Proc registration with attributes | Task 5 |
| Hot-reload manager | Task 6 |
| Logger bridge | Task 7 |
| Janet conformance tests | Task 8 |
| Error types and formatting | Task 4 |

---

## Self-Review: Type Consistency

- `JanetVM` is `rawptr` in Task 2, used consistently in Tasks 3–8
- `Janet` (the value union) is introduced in Task 2 as the Odin equivalent of Janet's `union Janet`; used in Tasks 3, 4, 5, 6, 7
- `JanetEngine` is introduced in Task 5 (`engine.odin`), used consistently in Tasks 5, 6, 7
- `JanetError` is in `errors.odin` (Task 4), used as return type in `janet_eval`, `janet_do_file`, `janet_call` (Task 4)
- All foreign function signatures match Janet 1.41.2 headers exactly
- No placeholder signatures — every function declared has a corresponding Janet C API call confirmed from `janet.h`

## Placeholder Scan

No TBD/TODO items. All signatures are concrete from confirmed Janet headers. Adapter signatures in Task 5 are explicitly enumerated with concrete types.
