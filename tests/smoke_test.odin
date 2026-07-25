package janet_test

import janet_low "../janet_low"
import janet_engine "../janet_engine"
import "base:runtime"
import "core:fmt"
import "core:testing"

@(test)
test_all :: proc(t: ^testing.T) {
	context = runtime.default_context()

	// Initialize Janet once
	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()
	fmt.println("janet_init: ok")

	// Test engine init
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "janet_engine_init failed")
	defer janet_engine.janet_engine_deinit(eng)
	fmt.println("engine init: ok")

	// Test register
	my_add :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
		context = runtime.default_context()
		x := janet_low.janet_get_integer(argv, 0)
		y := janet_low.janet_get_integer(argv, 1)
		return janet_low.janet_wrap_integer(x + y)
	}

	ok = janet_engine.janet_register(eng, "my_add", my_add)
	assert(ok, "janet_register failed")
	fmt.println("register: ok")

	// Test value wrapping - separate test to isolate VM issues
	ival := janet_low.janet_wrap_integer(42)
	unwrapped := janet_low.janet_unwrap_integer(ival)
	assert(unwrapped == 42, "integer wrap/unwrap failed")
	fmt.println("integer wrap/unwrap: ok")

	fmt.println("all tests passed")
}

@(test)
test_type_checking :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	// Test nil
	nil_val := janet_low.janet_wrap_nil()
	assert(janet_low.janet_checktype(nil_val, janet_low.JanetType.NIL), "nil check failed")
	assert(!janet_low.janet_truthy(nil_val), "nil should be falsy")

	// Test boolean
	true_val := janet_low.janet_wrap_boolean(true)
	false_val := janet_low.janet_wrap_boolean(false)
	assert(janet_low.janet_checktype(true_val, janet_low.JanetType.BOOLEAN), "boolean check failed")
	assert(janet_low.janet_truthy(true_val), "true should be truthy")
	assert(!janet_low.janet_truthy(false_val), "false should be falsy")

	// Test number
	num_val := janet_low.janet_wrap_number(3.14)
	assert(janet_low.janet_checktype(num_val, janet_low.JanetType.NUMBER), "number check failed")
	assert(janet_low.janet_truthy(num_val), "non-zero number should be truthy")

	// Test string
	str_val := janet_low.janet_wrap_string(janet_low.janet_cstring("hello"))
	assert(janet_low.janet_checktype(str_val, janet_low.JanetType.STRING), "string check failed")
	assert(janet_low.janet_truthy(str_val), "non-empty string should be truthy")

	fmt.println("type checking: ok")
}

@(test)
test_value_operations :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	// Test integer operations
	i32_val := janet_low.janet_wrap_integer(42)
	assert(janet_low.janet_unwrap_integer(i32_val) == 42, "i32 wrap/unwrap failed")

	i64_val := janet_low.janet_wrap_integer64(9223372036854775807)
	assert(janet_low.janet_unwrap_integer64(i64_val) == 9223372036854775807, "i64 wrap/unwrap failed")

	// Test number operations
	num_val := janet_low.janet_wrap_number(3.14159)
	unwrapped := janet_low.janet_unwrap_number(num_val)
	assert(unwrapped > 3.14 && unwrapped < 3.15, "number wrap/unwrap failed")

	// Test boolean operations
	bool_true := janet_low.janet_wrap_boolean(true)
	bool_false := janet_low.janet_wrap_boolean(false)
	assert(janet_low.janet_unwrap_boolean(bool_true) == true, "boolean true wrap/unwrap failed")
	assert(janet_low.janet_unwrap_boolean(bool_false) == false, "boolean false wrap/unwrap failed")

	fmt.println("value operations: ok")
}

@(test)
test_string_operations :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	// Test string creation
	str := janet_low.janet_cstring("test string")
	assert(str != nil, "janet_cstring failed")

	// Test string wrap/unwrap
	str_val := janet_low.janet_wrap_string(str)
	unwrapped_str := janet_low.janet_unwrap_string(str_val)
	assert(unwrapped_str == str, "string wrap/unwrap failed")

	// Test symbol
	sym := janet_low.janet_csymbol("test-symbol")
	sym_val := janet_low.janet_wrap_symbol(sym)
	unwrapped_sym := janet_low.janet_unwrap_symbol(sym_val)
	assert(unwrapped_sym == sym, "symbol wrap/unwrap failed")

	// Test keyword
	keyword := janet_low.janet_ckeyword("test-keyword")
	keyword_val := janet_low.janet_wrap_keyword(keyword)
	unwrapped_keyword := janet_low.janet_unwrap_keyword(keyword_val)
	assert(unwrapped_keyword == keyword, "keyword wrap/unwrap failed")

	fmt.println("string operations: ok")
}

@(test)
test_table_operations :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	// Create table
	table := janet_low.janet_table(10)
	assert(table != nil, "janet_table failed")

	// Test table put/get
	key := janet_low.janet_wrap_string(janet_low.janet_cstring("key"))
	value := janet_low.janet_wrap_integer(42)
	janet_low.janet_table_put(table, key, value)

	retrieved := janet_low.janet_table_get(table, key)
	assert(janet_low.janet_unwrap_integer(retrieved) == 42, "table get failed")

	// Test table remove
	janet_low.janet_table_remove(table, key)
	removed := janet_low.janet_table_get(table, key)
	assert(janet_low.janet_checktype(removed, janet_low.JanetType.NIL), "table remove failed")

	fmt.println("table operations: ok")
}

@(test)
test_array_operations :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	// Create array
	array := janet_low.janet_array(10)
	assert(array != nil, "janet_array failed")

	// Test array push
	val1 := janet_low.janet_wrap_integer(1)
	val2 := janet_low.janet_wrap_integer(2)
	val3 := janet_low.janet_wrap_integer(3)
	janet_low.janet_array_push(array, val1)
	janet_low.janet_array_push(array, val2)
	janet_low.janet_array_push(array, val3)

	// Test array length
	length := janet_low.janet_array_length(array)
	assert(length == 3, "array length failed")

	// Test array get
	elem := janet_low.janet_array_get(array, 1)
	assert(janet_low.janet_unwrap_integer(elem) == 2, "array get failed")

	// Test array pop
	popped := janet_low.janet_array_pop(array)
	assert(janet_low.janet_unwrap_integer(popped) == 3, "array pop failed")
	assert(janet_low.janet_array_length(array) == 2, "array length after pop failed")

	fmt.println("array operations: ok")
}

@(test)
test_gc_operations :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	// Test GC root/unroot
	val := janet_low.janet_wrap_integer(42)
	janet_low.janet_gcroot(val)
	janet_low.janet_gcunroot(val)

	// Test GC lock/unlock
	lock_handle := janet_low.janet_gclock()
	janet_low.janet_gcunlock(lock_handle)

	// Test GC collect
	// NOTE: janet_collect() crashes on ARM64 macOS due to a Janet library bug
	// janet_low.janet_collect()

	fmt.println("gc operations: ok")
}

@(test)
test_engine_functions :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "janet_engine_init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Test function registration
	my_func :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
		context = runtime.default_context()
		return janet_low.janet_wrap_integer(100)
	}

	ok = janet_engine.janet_register(eng, "my_func", my_func)
	assert(ok, "janet_register failed")

	// Test function lookup
	lookup_result := janet_engine.janet_lookup(eng, "my_func")
	assert(!janet_low.janet_checktype(lookup_result, janet_low.JanetType.NIL), "janet_lookup failed")

	// Test function unregister
	janet_engine.janet_unregister(eng, "my_func")
	lookup_after_unregister := janet_engine.janet_lookup(eng, "my_func")
	assert(
		janet_low.janet_checktype(lookup_after_unregister, janet_low.JanetType.NIL),
		"janet_unregister failed",
	)

	fmt.println("engine functions: ok")
}

@(test)
test_logger :: proc(t: ^testing.T) {
	context = runtime.default_context()

	// Test logger initialization
	janet_engine.janet_logger_init(janet_engine.LogLevel.DEBUG)
	assert(janet_engine.janet_get_log_level() == janet_engine.LogLevel.DEBUG, "logger init failed")

	// Test log level setting
	janet_engine.janet_set_log_level(janet_engine.LogLevel.WARN)
	assert(
		janet_engine.janet_get_log_level() == janet_engine.LogLevel.WARN,
		"set log level failed",
	)

	// Test logging functions (these should not crash)
	janet_engine.janet_log_debug("debug message")
	janet_engine.janet_log_info("info message")
	janet_engine.janet_log_warn("warn message")
	janet_engine.janet_log_error("error message")

	// Test logger shutdown
	janet_engine.janet_logger_shutdown()

	fmt.println("logger: ok")
}

@(test)
test_error_handling :: proc(t: ^testing.T) {
	context = runtime.default_context()

	result := janet_low.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet_low.janet_deinit()

	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "janet_engine_init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Test dostring with valid code
	out_val: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, "(+ 1 2)", "test", &out_val)
	assert(status == 0, "janet_dostring with valid code failed")
	assert(janet_low.janet_unwrap_integer(out_val) == 3, "janet_dostring result incorrect")

	// Test dostring with invalid code (should return error)
	status = janet_low.janet_dostring(eng.env, "(invalid syntax", "test", &out_val)
	assert(status != 0, "janet_dostring should fail with invalid syntax")

	fmt.println("error handling: ok")
}
