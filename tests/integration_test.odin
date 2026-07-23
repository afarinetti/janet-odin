package janet_test

import janet "../janet"
import janet_engine "../janet_engine"
import "core:fmt"
import "core:os"
import "core:testing"

// run_janet_test_suite - Execute a Janet test suite through our bindings
run_janet_test_suite :: proc(t: ^testing.T, suite_name: string, test_file: string) {
	// Save current directory
	cwd, _ := os.getwd(context.allocator)
	defer os.chdir(cwd)

	// Change to test directory so Janet can find ./helper
	os.chdir("vendor/janet/test")

	// Initialize Janet
	result := janet.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet.janet_deinit()

	// Create engine
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "janet_engine_init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Load and execute test file
	test_data, test_err := os.read_entire_file_from_path(test_file, context.allocator)
	assert(test_err == nil, "Failed to read test file")
	defer delete(test_data)

	test_out: janet.Janet
	status := janet.janet_dobytes(
		eng.env,
		raw_data(test_data),
		i32(len(test_data)),
		transmute(cstring)raw_data(test_file),
		&test_out,
	)
	if status != 0 {
		fmt.eprintf("%s failed with status %d\n", suite_name, status)
	}
	assert(status == 0, "Test suite failed")

	fmt.printf("%s: executed successfully through Odin bindings\n", suite_name)
}

@(test)
test_janet_suite_value_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-value", "suite-value.janet")
}

@(test)
test_janet_suite_array_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-array", "suite-array.janet")
}

@(test)
test_janet_suite_table_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-table", "suite-table.janet")
}

@(test)
test_janet_suite_string_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-string", "suite-string.janet")
}

@(test)
test_janet_suite_buffer_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-buffer", "suite-buffer.janet")
}

@(test)
test_janet_suite_tuple_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-tuple", "suite-tuple.janet")
}

@(test)
test_janet_suite_struct_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-struct", "suite-struct.janet")
}

@(test)
test_janet_suite_math_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-math", "suite-math.janet")
}

@(test)
test_janet_suite_specials_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-specials", "suite-specials.janet")
}

@(test)
test_janet_suite_compile_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-compile", "suite-compile.janet")
}

@(test)
test_janet_suite_parse_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-parse", "suite-parse.janet")
}

@(test)
test_janet_suite_pp_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-pp", "suite-pp.janet")
}

@(test)
test_janet_suite_inttypes_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-inttypes", "suite-inttypes.janet")
}

@(test)
test_janet_suite_marsh_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-marsh", "suite-marsh.janet")
}

@(test)
test_janet_suite_os_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-os", "suite-os.janet")
}

@(test)
test_janet_suite_io_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-io", "suite-io.janet")
}

@(test)
test_janet_suite_corelib_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-corelib", "suite-corelib.janet")
}

@(test)
test_janet_suite_ffi_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-ffi", "suite-ffi.janet")
}

@(test)
test_janet_suite_capi_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-capi", "suite-capi.janet")
}

@(test)
test_janet_suite_cfuns_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-cfuns", "suite-cfuns.janet")
}

@(test)
test_janet_suite_debug_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-debug", "suite-debug.janet")
}

@(test)
test_janet_suite_peg_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-peg", "suite-peg.janet")
}

@(test)
test_janet_suite_strtod_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-strtod", "suite-strtod.janet")
}

@(test)
test_janet_suite_symcache_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-symcache", "suite-symcache.janet")
}

@(test)
test_janet_suite_unknown_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-unknown", "suite-unknown.janet")
}

@(test)
test_janet_suite_vm_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-vm", "suite-vm.janet")
}

@(test)
test_janet_suite_boot_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-boot", "suite-boot.janet")
}

@(test)
test_janet_suite_net_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-net", "suite-net.janet")
}

@(test)
test_janet_suite_filewatch_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-filewatch", "suite-filewatch.janet")
}

@(test)
test_janet_suite_bundle_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-bundle", "suite-bundle.janet")
}

@(test)
test_janet_suite_asm_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-asm", "suite-asm.janet")
}

@(test)
test_janet_suite_ev_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-ev", "suite-ev.janet")
}

@(test)
test_janet_suite_ev2_via_odin :: proc(t: ^testing.T) {
	run_janet_test_suite(t, "suite-ev2", "suite-ev2.janet")
}
