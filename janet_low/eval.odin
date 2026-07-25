package janet_low

import "core:c"

// Compile status enum (mirrors C `enum JanetCompileStatus` - janet.h:1677)
JanetCompileStatus :: enum i32 {
	OK    = 0,
	ERROR = 1,
}

// Source mapping - mirrors C `struct JanetSourceMapping` (janet.h:1081: {line, column})
JanetSourceMapping :: struct {
	line:   i32,
	column: i32,
}

// Compile result - mirrors C `struct JanetCompileResult` (janet.h:1681).
// Field order is significant: it must match the C ABI for return-by-value.
JanetCompileResult :: struct {
	funcdef:       ^JanetFuncDef,
	error:         JanetString,
	macrofiber:    ^JanetFiber,
	error_mapping: JanetSourceMapping,
	status:        JanetCompileStatus,
}

// janet_compile - Compile Janet source to a function
janet_compile :: proc(
	source: Janet,
	env: ^JanetTable,
	source_name: JanetString,
) -> JanetCompileResult {
	return _janet_compile(source, env, source_name)
}

// janet_compile_lint - Compile with lint warnings
janet_compile_lint :: proc(
	source: Janet,
	env: ^JanetTable,
	source_name: JanetString,
	lint: ^JanetArray,
) -> JanetCompileResult {
	return _janet_compile_lint(source, env, source_name, lint)
}

// ===== Parser =====
// Thin public wrappers over the underscore-prefixed foreign declarations
// (see janet.odin). Exposed so callers can allocate a JanetParser and drive
// parsing without reaching past the public API.

// janet_parser_init - Initialize an allocated parser (call before use)
janet_parser_init :: proc(p: ^JanetParser) {_janet_parser_init(p)}

// janet_parser_deinit - Release parser-held resources
janet_parser_deinit :: proc(p: ^JanetParser) {_janet_parser_deinit(p)}

// janet_parser_consume - Feed one byte to the parser
janet_parser_consume :: proc(p: ^JanetParser, c: u8) {_janet_parser_consume(p, c)}

// janet_parser_eof - Signal end of input
janet_parser_eof :: proc(p: ^JanetParser) {_janet_parser_eof(p)}

// janet_parser_status - Raw status (0=root, 1=error, 2=pending, 3=dead)
janet_parser_status :: proc(p: ^JanetParser) -> i32 {return _janet_parser_status(p)}

// janet_parser_has_more - True if a parsed value is ready to produce
janet_parser_has_more :: proc(p: ^JanetParser) -> bool {return _janet_parser_has_more(p) != 0}

// janet_parser_produce - Pop the next parsed Janet value
janet_parser_produce :: proc(p: ^JanetParser) -> Janet {return _janet_parser_produce(p)}

// janet_parser_error - Error message when status == 1, else nil
janet_parser_error :: proc(p: ^JanetParser) -> cstring {return _janet_parser_error(p)}

// janet_parser_flush - Reset parser's pending buffer
janet_parser_flush :: proc(p: ^JanetParser) {_janet_parser_flush(p)}

// janet_dostring - Evaluate a string in the given environment
// Returns 0 on success, non-zero on error
janet_dostring :: proc(env: ^JanetTable, str: cstring, source_path: cstring, out: ^Janet) -> i32 {
	return _janet_dostring(env, str, source_path, out)
}

// janet_dobytes - Evaluate bytes in the given environment
// Returns 0 on success, non-zero on error
janet_dobytes :: proc(
	env: ^JanetTable,
	bytes: ^u8,
	len: i32,
	source_path: cstring,
	out: ^Janet,
) -> i32 {
	return _janet_dobytes(env, bytes, len, source_path, out)
}

// janet_call - Call a Janet function
janet_call :: proc(fun: ^JanetFunction, argc: i32, argv: ^Janet) -> Janet {
	return _janet_call(fun, argc, argv)
}

// janet_pcall - Protected call with error handling
janet_pcall :: proc(
	fun: ^JanetFunction,
	argc: i32,
	argv: ^Janet,
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
	argv: ^Janet,
) -> ^JanetFiber {
	return _janet_fiber(callee, capacity, argc, argv)
}

// janet_fiber_reset - Reset a fiber with a new function
janet_fiber_reset :: proc(fiber: ^JanetFiber, callee: ^JanetFunction, argc: i32, argv: ^Janet) {
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

// janet_fiber_setcapacity - Set the stack capacity of a fiber
janet_fiber_setcapacity :: proc(fiber: ^JanetFiber, capacity: i32) {
	_janet_fiber_setcapacity(fiber, capacity)
}

// janet_continue - Resume a fiber with input
janet_continue :: proc(fiber: ^JanetFiber, in_val: Janet, out: ^Janet) -> JanetSignal {
	return _janet_continue(fiber, in_val, out)
}

// janet_continue_signal - Resume a fiber with input and signal
janet_continue_signal :: proc(
	fiber: ^JanetFiber,
	in_val: Janet,
	out: ^Janet,
	signal: JanetSignal,
) -> JanetSignal {
	return _janet_continue_signal(fiber, in_val, out, signal)
}

// janet_stacktrace - Format a stacktrace for an error
janet_stacktrace :: proc(fiber: ^JanetFiber, err: Janet) {
	_janet_stacktrace(fiber, err)
}

// janet_root_fiber - Get the root fiber
janet_root_fiber :: proc() -> ^JanetFiber {
	return _janet_root_fiber()
}

// janet_current_fiber - Get the current fiber
janet_current_fiber :: proc() -> ^JanetFiber {
	return _janet_current_fiber()
}

// janet_cstring_to_janet - Convert C string to Janet string value
janet_cstring_to_janet :: proc(cstr: cstring) -> Janet {
	return _janet_wrap_string(_janet_cstring(cstr))
}

// janet_to_string - Convert Janet value to string value
janet_to_string :: proc(x: Janet) -> Janet {
	return _janet_wrap_string(_janet_to_string(x))
}

// janet_description - Get a description string for a Janet value
janet_description :: proc(x: Janet) -> JanetString {
	return _janet_description(x)
}

// Event loop

// janet_loop - Run the event loop until all fibers are done
janet_loop :: proc() {
	_janet_loop()
}

// janet_loop_done - Check if the event loop is done
janet_loop_done :: proc() -> bool {
	return _janet_loop_done() != 0
}

// janet_loop1 - Run one iteration of the event loop
janet_loop1 :: proc() -> ^JanetFiber {
	return _janet_loop1()
}

// janet_loop1_interrupt - Interrupt the event loop
janet_loop1_interrupt :: proc(vm: ^JanetVM) {
	_janet_loop1_interrupt(vm)
}

// janet_loop_fiber - Run a fiber in the event loop
janet_loop_fiber :: proc(fiber: ^JanetFiber) -> i32 {
	return _janet_loop_fiber(fiber)
}

// janet_schedule - Schedule a fiber to run
janet_schedule :: proc(fiber: ^JanetFiber, value: Janet) {
	_janet_schedule(fiber, value)
}

// janet_schedule_signal - Schedule a fiber with a signal
janet_schedule_signal :: proc(fiber: ^JanetFiber, value: Janet, sig: JanetSignal) {
	_janet_schedule_signal(fiber, value, sig)
}

// janet_cancel - Cancel a fiber
janet_cancel :: proc(fiber: ^JanetFiber, value: Janet) {
	_janet_cancel(fiber, value)
}
