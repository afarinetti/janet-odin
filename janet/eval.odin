package janet

import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

// Compile status enum
JanetCompileStatus :: enum i32 {
	OK    = 0,
	ERROR = 1,
}

// Compile result from janet_compile
JanetCompileResult :: struct {
	funcdef:       ^JanetFunction,
	error:         JanetString,
	macrofiber:    ^JanetFiber,
	error_mapping: JanetSourceMapping,
	status:        JanetCompileStatus,
}

// Source mapping for error reporting
JanetSourceMapping :: struct {
	line:   i32,
	column: i32,
}

// janet_compile - Compile Janet source to a function
janet_compile :: proc(
	source: JanetString,
	env: ^JanetTable,
	source_name: JanetString,
) -> JanetCompileResult {
	return _janet_compile(source, env, source_name)
}

// janet_dostring - Evaluate a string in the given environment
// Returns 0 on success, non-zero on error
janet_dostring :: proc(env: ^JanetTable, str: cstring, source_path: cstring, out: ^Janet) -> i32 {
	return _janet_dostring(env, str, source_path, out)
}

// janet_call - Call a Janet function
janet_call :: proc(fun: ^JanetFunction, argc: i32, argv: [^]Janet) -> Janet {
	return _janet_call(fun, argc, argv)
}

// janet_pcall - Protected call with error handling
janet_pcall :: proc(
	fun: ^JanetFunction,
	argc: i32,
	argv: [^]Janet,
	out: ^Janet,
	fiber: ^^JanetFiber,
) -> JanetSignal {
	return _janet_pcall(fun, argc, argv, out, fiber)
}

// janet_fiber - Create a new fiber for coroutine
janet_fiber :: proc(
	callee: ^JanetFunction,
	capacity: i32,
	argc: i32,
	argv: [^]Janet,
) -> ^JanetFiber {
	return _janet_fiber(callee, capacity, argc, argv)
}

// janet_fiber_reset - Reset a fiber with a new function
janet_fiber_reset :: proc(fiber: ^JanetFiber, callee: ^JanetFunction, argc: i32, argv: [^]Janet) {
	_janet_fiber_reset(fiber, callee, argc, argv)
}

// janet_fiber_status - Get fiber's current status
janet_fiber_status :: proc(fiber: ^JanetFiber) -> JanetFiberStatus {
	return _janet_fiber_status(fiber)
}

// janet_fiber_can_resume - Check if fiber can be resumed
janet_fiber_can_resume :: proc(fiber: ^JanetFiber) -> bool {
	return _janet_fiber_can_resume(fiber) != 0
}

// janet_continue - Resume a fiber with input
janet_continue :: proc(fiber: ^JanetFiber, in_val: Janet, out: ^Janet) -> JanetSignal {
	return _janet_continue(fiber, in_val, out)
}

// janet_stacktrace - Format a stacktrace for an error
janet_stacktrace :: proc(fiber: ^JanetFiber, err: Janet) {
	_janet_stacktrace(fiber, err)
}

// janet_cstring_to_janet - Convert C string to Janet string
janet_cstring_to_janet :: proc(cstr: cstring) -> Janet {
	return _janet_cstring_to_janet(cstr)
}

// janet_to_string - Convert Janet value to string
janet_to_string :: proc(x: Janet) -> Janet {
	return _janet_to_string(x)
}

// Foreign imports
foreign janet_lib {
	@(link_name = "janet_compile")
	_janet_compile :: proc(source: JanetString, env: ^JanetTable, source_name: JanetString) -> JanetCompileResult ---

	@(link_name = "janet_dostring")
	_janet_dostring :: proc(env: ^JanetTable, str: cstring, source_path: cstring, out: ^Janet) -> i32 ---

	@(link_name = "janet_call")
	_janet_call :: proc(fun: ^JanetFunction, argc: i32, argv: [^]Janet) -> Janet ---

	@(link_name = "janet_pcall")
	_janet_pcall :: proc(fun: ^JanetFunction, argc: i32, argv: [^]Janet, out: ^Janet, fiber: ^^JanetFiber) -> JanetSignal ---

	@(link_name = "janet_fiber")
	_janet_fiber :: proc(callee: ^JanetFunction, capacity: i32, argc: i32, argv: [^]Janet) -> ^JanetFiber ---

	@(link_name = "janet_fiber_reset")
	_janet_fiber_reset :: proc(fiber: ^JanetFiber, callee: ^JanetFunction, argc: i32, argv: [^]Janet) ---

	@(link_name = "janet_fiber_status")
	_janet_fiber_status :: proc(fiber: ^JanetFiber) -> JanetFiberStatus ---

	@(link_name = "janet_fiber_can_resume")
	_janet_fiber_can_resume :: proc(fiber: ^JanetFiber) -> i32 ---

	@(link_name = "janet_continue")
	_janet_continue :: proc(fiber: ^JanetFiber, in_val: Janet, out: ^Janet) -> JanetSignal ---

	@(link_name = "janet_stacktrace")
	_janet_stacktrace :: proc(fiber: ^JanetFiber, err: Janet) ---

	@(link_name = "janet_cstring_to_janet")
	_janet_cstring_to_janet :: proc(cstr: cstring) -> Janet ---

	@(link_name = "janet_to_string")
	_janet_to_string :: proc(x: Janet) -> Janet ---
}
