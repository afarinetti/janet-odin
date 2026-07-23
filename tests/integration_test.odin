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
	status := janet.janet_dostring(
		eng.env,
		transmute(cstring)raw_data(test_data),
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
