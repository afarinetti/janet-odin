package janet_test

import janet "../janet"
import janet_engine "../janet_engine"
import "base:runtime"
import "core:fmt"
import "core:os"
import "core:testing"

// Var binding for exec_janet_with_env
VarBinding :: struct {
	name:  string,
	value: janet.Janet,
}

// Helper to execute Janet code and return the result
exec_janet :: proc(eng: ^janet_engine.JanetEngine, code: string) -> (janet.Janet, bool) {
	out: janet.Janet
	status := janet.janet_dostring(
		eng.env,
		transmute(cstring)raw_data(code),
		transmute(cstring)raw_data(code),
		&out,
	)
	return out, status == 0
}

// Helper to execute Janet code with Odin values in scope
exec_janet_with_env :: proc(
	eng: ^janet_engine.JanetEngine,
	code: string,
	vars: []VarBinding,
) -> (
	janet.Janet,
	bool,
) {
	for v in vars {
		name_cstr := transmute(cstring)raw_data(v.name)
		janet.janet_def(eng.env, name_cstr, v.value, "")
	}
	return exec_janet(eng, code)
}

// ============================================================================
// Basic Type Interop
// ============================================================================

@(test)
test_interop_numbers :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Odin integer -> Janet -> Odin
	odin_int := janet.janet_wrap_integer(42)
	bindings := [1]VarBinding{VarBinding{"n", odin_int}}
	result1, ok1 := exec_janet_with_env(eng, "(+ n 10)", bindings[:])
	assert(ok1, "execution failed")
	assert(janet.janet_unwrap_integer(result1) == 52, "integer interop failed")

	// Odin float -> Janet -> Odin
	odin_float := janet.janet_wrap_number(3.14)
	bindings = [1]VarBinding{VarBinding{"n", odin_float}}
	result2, ok2 := exec_janet_with_env(eng, "(* n 2.0)", bindings[:])
	assert(ok2, "execution failed")
	assert(janet.janet_unwrap_number(result2) == 6.28, "float interop failed")

	// Janet number -> Odin
	result3, ok3 := exec_janet(eng, "(/ 10 4)")
	assert(ok3, "execution failed")
	assert(janet.janet_unwrap_number(result3) == 2.5, "janet number to odin failed")

	fmt.println("  number interop: integer, float, division")
}

@(test)
test_interop_booleans :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Odin true -> Janet
	odin_true := janet.janet_wrap_true()
	bindings := [1]VarBinding{VarBinding{"b", odin_true}}
	result1, ok1 := exec_janet_with_env(eng, "(if b :yes :no)", bindings[:])
	assert(ok1, "execution failed")
	assert(janet.janet_checktype(result1, .KEYWORD), "expected keyword")

	// Odin false -> Janet
	odin_false := janet.janet_wrap_false()
	bindings = [1]VarBinding{VarBinding{"b", odin_false}}
	result2, ok2 := exec_janet_with_env(eng, "(if b :yes :no)", bindings[:])
	assert(ok2, "execution failed")
	assert(janet.janet_checktype(result2, .KEYWORD), "expected keyword")

	// Janet boolean -> Odin
	result3, ok3 := exec_janet(eng, "(> 5 3)")
	assert(ok3, "execution failed")
	assert(janet.janet_truthy(result3), "expected truthy")

	fmt.println("  boolean interop: true, false, truthy")
}

@(test)
test_interop_strings :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Odin string -> Janet -> Odin
	odin_str := janet.janet_wrap_string(janet.janet_cstring("hello"))
	bindings := [1]VarBinding{VarBinding{"s", odin_str}}
	result1, ok1 := exec_janet_with_env(eng, "(string s s)", bindings[:])
	assert(ok1, "execution failed")
	assert(janet.janet_checktype(result1, .STRING), "expected string")

	// Janet string -> Odin
	result2, ok2 := exec_janet(eng, "\"world\"")
	assert(ok2, "execution failed")
	str := janet.janet_unwrap_string(result2)
	assert(str != nil, "expected non-nil string")

	fmt.println("  string interop: creation, concatenation, retrieval")
}
// ============================================================================
// Collection Interop
// ============================================================================

@(test)
test_interop_arrays :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Create Odin array and pass to Janet
	odin_arr := janet.janet_array(3)
	janet.janet_array_push(odin_arr, janet.janet_wrap_integer(1))
	janet.janet_array_push(odin_arr, janet.janet_wrap_integer(2))
	janet.janet_array_push(odin_arr, janet.janet_wrap_integer(3))

	arr_val := janet.janet_wrap_array(odin_arr)
	bindings := [1]VarBinding{VarBinding{"arr", arr_val}}
	result1, ok1 := exec_janet_with_env(eng, "(length arr)", bindings[:])
	assert(ok1, "execution failed")
	assert(janet.janet_unwrap_integer(result1) == 3, "array length failed")

	// Janet array operations
	bindings = [1]VarBinding{VarBinding{"arr", arr_val}}
	result2, ok2 := exec_janet_with_env(eng, "(array/push arr 4)", bindings[:])
	assert(ok2, "execution failed")

	// Verify from Odin side
	assert(janet.janet_array_length(odin_arr) == 4, "array push failed")

	// Janet array -> Odin
	result3, ok3 := exec_janet(eng, "@[10 20 30 40 50]")
	assert(ok3, "execution failed")
	arr := janet.janet_unwrap_array(result3)
	assert(janet.janet_array_length(arr) == 5, "janet array length failed")
	assert(janet.janet_unwrap_integer(janet.janet_array_get(arr, 2)) == 30, "array get failed")

	fmt.println("  array interop: creation, push, length, get")
}

@(test)
test_interop_tables :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Create Odin table and pass to Janet
	odin_table := janet.janet_table(0)
	key1 := janet.janet_wrap_keyword(janet.janet_ckeyword("name"))
	val1 := janet.janet_wrap_string(janet.janet_cstring("Alice"))
	janet.janet_table_put(odin_table, key1, val1)

	key2 := janet.janet_wrap_keyword(janet.janet_ckeyword("age"))
	val2 := janet.janet_wrap_integer(30)
	janet.janet_table_put(odin_table, key2, val2)

	table_val := janet.janet_wrap_table(odin_table)
	bindings := [1]VarBinding{VarBinding{"tbl", table_val}}
	result1, ok1 := exec_janet_with_env(eng, "(get tbl :name)", bindings[:])
	assert(ok1, "execution failed")
	assert(janet.janet_checktype(result1, .STRING), "expected string")

	// Janet table operations
	bindings = [1]VarBinding{VarBinding{"tbl", table_val}}
	result2, ok2 := exec_janet_with_env(eng, "(put tbl :city \"Seattle\")", bindings[:])
	assert(ok2, "execution failed")

	// Verify from Odin side
	key3 := janet.janet_wrap_keyword(janet.janet_ckeyword("city"))
	city := janet.janet_table_get(odin_table, key3)
	assert(janet.janet_checktype(city, .STRING), "city not found")

	// Janet table -> Odin
	result3, ok3 := exec_janet(eng, "@{:x 10 :y 20 :z 30}")
	assert(ok3, "execution failed")
	table := janet.janet_unwrap_table(result3)
	key4 := janet.janet_wrap_keyword(janet.janet_ckeyword("y"))
	y_val := janet.janet_table_get(table, key4)
	assert(janet.janet_unwrap_integer(y_val) == 20, "table get failed")

	fmt.println("  table interop: creation, put, get, keyword keys")
}

// ============================================================================
// Function Interop
// ============================================================================

@(test)
test_interop_odin_functions :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Define Odin function callable from Janet
	odin_multiply :: proc "c" (argc: i32, argv: ^janet.Janet) -> janet.Janet {
		context = runtime.default_context()
		assert(argc == 2, "expected 2 args")
		a := janet.janet_get_number(argv, 0)
		b := janet.janet_get_number(argv, 1)
		return janet.janet_wrap_number(a * b)
	}
	ok = janet_engine.janet_register(eng, "odin_multiply", odin_multiply)
	assert(ok, "register failed")

	// Call Odin function from Janet
	result1, ok1 := exec_janet(eng, "(odin_multiply 6.0 7.0)")
	assert(ok1, "execution failed")
	assert(janet.janet_unwrap_number(result1) == 42.0, "odin function call failed")

	// Use in higher-order context
	result2, ok2 := exec_janet(eng, "(map odin_multiply @[2.0 3.0 4.0] @[5.0 5.0 5.0])")
	assert(ok2, "execution failed")
	arr := janet.janet_unwrap_array(result2)
	assert(janet.janet_array_length(arr) == 3, "expected 3 results")
	assert(janet.janet_unwrap_number(janet.janet_array_get(arr, 0)) == 10.0, "map failed")
	assert(janet.janet_unwrap_number(janet.janet_array_get(arr, 1)) == 15.0, "map failed")
	assert(janet.janet_unwrap_number(janet.janet_array_get(arr, 2)) == 20.0, "map failed")

	fmt.println("  function interop: odin->janet, higher-order")
}

@(test)
test_interop_janet_functions :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Define Janet function
	_, ok1 := exec_janet(eng, "(defn janet_add [a b] (+ a b))")
	assert(ok1, "define failed")

	// Call Janet function from Odin via Janet code
	result, ok2 := exec_janet(eng, "(janet_add 10 20)")
	assert(ok2, "execution failed")
	assert(janet.janet_unwrap_integer(result) == 30, "janet function call failed")

	fmt.println("  function interop: janet->odin, direct call")
}

// ============================================================================
// Complex Data Structures
// ============================================================================

@(test)
test_interop_nested_structures :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Create nested structure: @{:users @[@{:name "Alice" :age 30} @{:name "Bob" :age 25}]}
	outer_table := janet.janet_table(0)
	users_array := janet.janet_array(2)

	// User 1
	user1 := janet.janet_table(0)
	key1 := janet.janet_wrap_keyword(janet.janet_ckeyword("name"))
	val1 := janet.janet_wrap_string(janet.janet_cstring("Alice"))
	janet.janet_table_put(user1, key1, val1)
	key2 := janet.janet_wrap_keyword(janet.janet_ckeyword("age"))
	val2 := janet.janet_wrap_integer(30)
	janet.janet_table_put(user1, key2, val2)
	janet.janet_array_push(users_array, janet.janet_wrap_table(user1))

	// User 2
	user2 := janet.janet_table(0)
	key3 := janet.janet_wrap_keyword(janet.janet_ckeyword("name"))
	val3 := janet.janet_wrap_string(janet.janet_cstring("Bob"))
	janet.janet_table_put(user2, key3, val3)
	key4 := janet.janet_wrap_keyword(janet.janet_ckeyword("age"))
	val4 := janet.janet_wrap_integer(25)
	janet.janet_table_put(user2, key4, val4)
	janet.janet_array_push(users_array, janet.janet_wrap_table(user2))

	key5 := janet.janet_wrap_keyword(janet.janet_ckeyword("users"))
	janet.janet_table_put(outer_table, key5, janet.janet_wrap_array(users_array))

	data_val := janet.janet_wrap_table(outer_table)
	bindings := [1]VarBinding{VarBinding{"data", data_val}}

	// Query from Janet
	result1, ok1 := exec_janet_with_env(eng, "(length (get data :users))", bindings[:])
	assert(ok1, "execution failed")
	assert(janet.janet_unwrap_integer(result1) == 2, "nested array length failed")

	bindings = [1]VarBinding{VarBinding{"data", data_val}}
	result2, ok2 := exec_janet_with_env(eng, "(get (get (get data :users) 0) :name)", bindings[:])
	assert(ok2, "execution failed")
	assert(janet.janet_checktype(result2, .STRING), "expected string")

	// Modify from Janet
	bindings = [1]VarBinding{VarBinding{"data", data_val}}
	_, ok3 := exec_janet_with_env(eng, "(put (get (get data :users) 1) :age 26)", bindings[:])
	assert(ok3, "execution failed")

	// Verify modification from Odin
	user2_updated := janet.janet_unwrap_table(janet.janet_array_get(users_array, 1))
	key6 := janet.janet_wrap_keyword(janet.janet_ckeyword("age"))
	new_age := janet.janet_table_get(user2_updated, key6)
	assert(janet.janet_unwrap_integer(new_age) == 26, "nested modification failed")

	fmt.println("  nested structures: tables in arrays, deep access, mutation")
}

@(test)
test_interop_mixed_types :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Array with mixed types
	mixed := janet.janet_array(5)
	janet.janet_array_push(mixed, janet.janet_wrap_integer(42))
	janet.janet_array_push(mixed, janet.janet_wrap_number(3.14))
	janet.janet_array_push(mixed, janet.janet_wrap_string(janet.janet_cstring("hello")))
	janet.janet_array_push(mixed, janet.janet_wrap_true())
	janet.janet_array_push(mixed, janet.janet_wrap_nil())

	mixed_val := janet.janet_wrap_array(mixed)
	bindings := [1]VarBinding{VarBinding{"mixed", mixed_val}}

	// Verify types from Janet
	result1, ok1 := exec_janet_with_env(eng, "(map type mixed)", bindings[:])
	assert(ok1, "execution failed")
	type_arr := janet.janet_unwrap_array(result1)
	assert(janet.janet_array_length(type_arr) == 5, "expected 5 types")

	fmt.println("  mixed types: integer, float, string, boolean, nil in array")
}

// ============================================================================
// Error Handling
// ============================================================================

@(test)
test_interop_error_handling :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Janet error -> Odin
	_, ok1 := exec_janet(eng, "(error \"something went wrong\")")
	assert(!ok1, "should have failed")

	// Odin can catch Janet errors with janet_pcall
	func_val, ok2 := exec_janet(eng, "(fn [] (error \"test error\"))")
	assert(ok2, "define failed")
	func := janet.janet_unwrap_function(func_val)

	out: janet.Janet
	fiber: ^janet.JanetFiber
	signal := janet.janet_pcall(func, 0, nil, &out, &fiber)
	assert(i32(signal) != 0, "expected error signal")

	fmt.println("  error handling: janet errors, pcall")
}

// ============================================================================
// Real-world Patterns
// ============================================================================

@(test)
test_interop_config_loading :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Simulate loading config from Janet
	config_code := `
		@{
			:host "localhost"
			:port 8080
			:debug true
			:workers 4
			:features @[:auth :logging :metrics]
		}
	`


	result1, ok1 := exec_janet(eng, config_code)
	assert(ok1, "execution failed")
	config := janet.janet_unwrap_table(result1)

	// Read config values in Odin
	host_key := janet.janet_wrap_keyword(janet.janet_ckeyword("host"))
	host := janet.janet_table_get(config, host_key)
	assert(janet.janet_checktype(host, .STRING), "host should be string")

	port_key := janet.janet_wrap_keyword(janet.janet_ckeyword("port"))
	port := janet.janet_table_get(config, port_key)
	assert(janet.janet_unwrap_integer(port) == 8080, "port should be 8080")

	debug_key := janet.janet_wrap_keyword(janet.janet_ckeyword("debug"))
	debug := janet.janet_table_get(config, debug_key)
	assert(janet.janet_truthy(debug), "debug should be true")

	features_key := janet.janet_wrap_keyword(janet.janet_ckeyword("features"))
	features := janet.janet_table_get(config, features_key)
	features_arr := janet.janet_unwrap_array(features)
	assert(janet.janet_array_length(features_arr) == 3, "should have 3 features")

	fmt.println("  config loading: table with mixed types, nested array")
}

@(test)
test_interop_data_processing :: proc(t: ^testing.T) {
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	// Define processing function in Janet
	_, ok1 := exec_janet(
		eng,
		`
		(defn process-data [data]
			(->> data
				(filter (fn [x] (> x 10)))
				(map (fn [x] (* x 2)))
				(sort)))
	`,
	)
	assert(ok1, "define failed")

	// Create data in Odin
	data := janet.janet_array(6)
	for i := i32(0); i < 6; i += 1 {
		janet.janet_array_push(data, janet.janet_wrap_integer(i * 3))
	}

	data_val := janet.janet_wrap_array(data)
	bindings := [1]VarBinding{VarBinding{"data", data_val}}
	result1, ok2 := exec_janet_with_env(eng, "(process-data data)", bindings[:])
	assert(ok2, "execution failed")

	result_arr := janet.janet_unwrap_array(result1)
	// Expected: [24 30] (filtered >10, multiplied by 2, sorted)
	assert(janet.janet_array_length(result_arr) == 2, "expected 2 results")
	assert(
		janet.janet_unwrap_integer(janet.janet_array_get(result_arr, 0)) == 24,
		"first result wrong",
	)
	assert(
		janet.janet_unwrap_integer(janet.janet_array_get(result_arr, 1)) == 30,
		"second result wrong",
	)

	fmt.println("  data processing: filter, map, sort pipeline")
}
