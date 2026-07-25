package janet_test

import janet "../janet"
import janet_engine "../janet_engine"
import janet_low "../janet_low"
import "base:runtime"
import "core:fmt"
import "core:testing"

// Test value construction and extraction
@(test)
test_high_level_value_construction :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Test nil
	nil_val := janet.janet_nil()
	_, ok_nil := nil_val.(janet.Nil)
	assert(ok_nil, "nil value should be extractable as nil")

	// Test boolean
	bool_val := janet.janet_bool(true)
	b, ok_bool := janet.to_bool(bool_val)
	assert(ok_bool && b, "bool value should be extractable as true")

	// Test integer
	int_val := janet.janet_integer(42)
	i, ok_int := janet.to_integer(int_val)
	assert(ok_int && i == 42, "integer value should be extractable as 42")

	// Test float
	float_val := janet.janet_float(3.14)
	f, ok_float := janet.to_float(float_val)
	assert(ok_float && f == 3.14, "float value should be extractable as 3.14")

	// Test string
	str_val := janet.janet_string("hello")
	s, ok_str := janet.to_string(str_val)
	assert(ok_str && s == "hello", "string value should be extractable as 'hello'")

	// Test array
	arr_items := []janet.JanetValue {
		janet.janet_integer(1),
		janet.janet_integer(2),
		janet.janet_integer(3),
	}
	arr_val := janet.janet_array(arr_items)
	arr, ok_arr := janet.to_array(arr_val)
	assert(ok_arr && len(arr) == 3, "array value should be extractable with 3 elements")

	// Test table
	tbl_pairs := make(map[string]janet.JanetValue)
	tbl_pairs["key1"] = janet.janet_integer(10)
	tbl_pairs["key2"] = janet.janet_integer(20)
	tbl_val := janet.janet_table(tbl_pairs)
	tbl, ok_tbl := janet.to_table(tbl_val)
	assert(ok_tbl && len(tbl) == 2, "table value should be extractable with 2 entries")
}

// Test function registration
@(test)
test_high_level_function_registration :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Register a simple add function
	add_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		if len(args) != 2 {
			return janet.janet_nil()
		}
		a, ok1 := janet.to_integer(args[0])
		b, ok2 := janet.to_integer(args[1])
		if !ok1 || !ok2 {
			return janet.janet_nil()
		}
		return janet.janet_integer(a + b)
	}

	success := janet.register(eng, "add", add_fn)
	assert(success, "function registration should succeed")

	// Call the function from Janet code
	result, err := janet.eval(eng, "(add 5 3)")
	assert(err == janet.JanetError.NONE, "function call should succeed")

	val, ok_val := janet.to_integer(result)
	assert(ok_val && val == 8, "add(5, 3) should return 8")
}

// Test eval string
@(test)
test_high_level_eval_string :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Test simple expression
	result, err := janet.eval(eng, "(+ 1 2)")
	assert(err == janet.JanetError.NONE, "eval should succeed")
	val, ok_val := janet.to_integer(result)
	assert(ok_val && val == 3, "(+ 1 2) should return 3")

	// Test string expression
	result, err = janet.eval(eng, `"hello world"`)
	assert(err == janet.JanetError.NONE, "eval should succeed")
	s, ok_str := janet.to_string(result)
	assert(ok_str && s == "hello world", "eval should return 'hello world'")

	// Test array expression
	result, err = janet.eval(eng, "@[1 2 3]")
	assert(err == janet.JanetError.NONE, "eval should succeed")
	arr, ok_arr := janet.to_array(result)
	assert(ok_arr && len(arr) == 3, "eval should return array with 3 elements")
}

// Test error handling
@(test)
test_high_level_error_handling :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Test syntax error
	_, err := janet.eval(eng, "(invalid syntax here")
	assert(err != janet.JanetError.NONE, "syntax error should be reported")
}

// Test string operations
@(test)
test_high_level_string_operations :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Register a string manipulation function
	upper_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		if len(args) != 1 {
			return janet.janet_nil()
		}
		s, ok := janet.to_string(args[0])
		if !ok {
			return janet.janet_nil()
		}
		// Simple uppercase implementation - iterate over bytes
		result := make([]byte, len(s))
		for i in 0 ..< len(s) {
			c := s[i]
			if c >= 'a' && c <= 'z' {
				result[i] = c - 32
			} else {
				result[i] = c
			}
		}
		return janet.janet_string(string(result))
	}

	janet.register(eng, "upper", upper_fn)

	result, err := janet.eval(eng, `(upper "hello")`)
	assert(err == janet.JanetError.NONE, "function call should succeed")
	val, ok_val := janet.to_string(result)
	assert(ok_val && val == "HELLO", "upper('hello') should return 'HELLO'")
}

// Test array operations
@(test)
test_high_level_array_operations :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Register a function that creates an array
	make_array_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		items := []janet.JanetValue {
			janet.janet_integer(1),
			janet.janet_integer(2),
			janet.janet_integer(3),
		}
		return janet.janet_array(items)
	}

	janet.register(eng, "make-array", make_array_fn)

	result, err := janet.eval(eng, "(make-array)")
	assert(err == janet.JanetError.NONE, "eval should succeed")

	// Check the array - verify it has the right length
	arr, ok_arr := janet.to_array(result)
	assert(ok_arr, "Could not convert result to array")
	assert(len(arr) == 3, "Array should have 3 elements")
}
