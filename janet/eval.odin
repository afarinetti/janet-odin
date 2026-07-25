package janet

import janet_low "../janet_low"
import janet_engine "../janet_engine"
import "core:c"
import "core:mem"
import "core:os"

// eval - Evaluate a Janet code string and return the result as a JanetValue.
// Returns (value, error) where error is NONE on success.
eval :: proc(eng: ^janet_engine.JanetEngine, code: string) -> (JanetValue, JanetError) {
	cstr := transmute(cstring)mem.raw_data(code)
	source_path_str := "eval"
	source_path := transmute(cstring)mem.raw_data(source_path_str)

	out: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, cstr, source_path, &out)

	if status != 0 {
		return Nil{}, .RUNTIME_ERROR
	}

	return janet_to_value(out)
}

// eval_file - Evaluate a Janet script file and return the result as a JanetValue.
// Returns (value, error) where error is NONE on success.
// Returns FILE_NOT_FOUND if the file doesn't exist.
eval_file :: proc(eng: ^janet_engine.JanetEngine, path: string) -> (JanetValue, JanetError) {
	// Read the file contents
	data, err := os.read_entire_file_from_path(path, context.allocator)
	if err != nil {
		return Nil{}, .FILE_NOT_FOUND
	}
	defer delete(data)

	source_path := transmute(cstring)mem.raw_data(path)

	out: janet_low.Janet
	status := janet_low.janet_dobytes(eng.env, &data[0], i32(len(data)), source_path, &out)

	if status != 0 {
		return Nil{}, .RUNTIME_ERROR
	}

	return janet_to_value(out)
}

// call - Call a Janet function by name with the given arguments.
// Returns (value, error) where error is NONE on success.
call :: proc(
	eng: ^janet_engine.JanetEngine,
	fn_name: string,
	args: []JanetValue,
) -> (
	JanetValue,
	JanetError,
) {
	// Look up the function in the environment
	sym_name := transmute(cstring)mem.raw_data(fn_name)
	sym := janet_low.janet_csymbol(sym_name)
	fn_val: janet_low.Janet
	binding := janet_low.janet_resolve(eng.env, sym, &fn_val)

	if binding == .NONE {
		return Nil{}, .RUNTIME_ERROR
	}

	// Get the function pointer
	fn_ptr := janet_low.janet_unwrap_function(fn_val)

	// Convert arguments to Janet values
	argc := i32(len(args))
	argv := make([]janet_low.Janet, argc)
	for i in 0 ..< argc {
		j, jerr := value_to_janet(args[i])
		if jerr != .NONE {
			return Nil{}, .TYPE_ERROR
		}
		argv[i] = j
	}

	// Call the function
	out: janet_low.Janet
	fiber: ^janet_low.JanetFiber
	signal := janet_low.janet_pcall(fn_ptr, argc, &argv[0], &out, &fiber)

	if signal != .OK {
		return Nil{}, .RUNTIME_ERROR
	}

	return janet_to_value(out)
}
