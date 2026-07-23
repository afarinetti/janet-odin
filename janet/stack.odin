package janet

import "core:c"

// Stack accessors - get values from argc/argv in C function callbacks

janet_get_boolean :: proc(argv: ^Janet, n: i32) -> bool {
	return _janet_getboolean(argv, n) != 0
}

janet_get_integer :: proc(argv: ^Janet, n: i32) -> i32 {
	return _janet_getinteger(argv, n)
}

janet_get_integer64 :: proc(argv: ^Janet, n: i32) -> i64 {
	return _janet_getinteger64(argv, n)
}

janet_get_number :: proc(argv: ^Janet, n: i32) -> f64 {
	return _janet_getnumber(argv, n)
}

janet_get_string :: proc(argv: ^Janet, n: i32) -> JanetString {
	return _janet_getstring(argv, n)
}

janet_get_cstring :: proc(argv: ^Janet, n: i32) -> cstring {
	return _janet_getcstring(argv, n)
}

janet_get_symbol :: proc(argv: ^Janet, n: i32) -> JanetSymbol {
	return _janet_getsymbol(argv, n)
}

janet_get_keyword :: proc(argv: ^Janet, n: i32) -> JanetKeyword {
	return _janet_getkeyword(argv, n)
}

janet_get_array :: proc(argv: ^Janet, n: i32) -> ^JanetArray {
	return _janet_getarray(argv, n)
}

janet_get_tuple :: proc(argv: ^Janet, n: i32) -> JanetTuple {
	return _janet_gettuple(argv, n)
}

janet_get_table :: proc(argv: ^Janet, n: i32) -> ^JanetTable {
	return _janet_gettable(argv, n)
}

janet_get_struct :: proc(argv: ^Janet, n: i32) -> JanetStruct {
	return _janet_getstruct(argv, n)
}

janet_get_buffer :: proc(argv: ^Janet, n: i32) -> ^JanetBuffer {
	return _janet_getbuffer(argv, n)
}

janet_get_fiber :: proc(argv: ^Janet, n: i32) -> ^JanetFiber {
	return _janet_getfiber(argv, n)
}

janet_get_function :: proc(argv: ^Janet, n: i32) -> ^JanetFunction {
	return _janet_getfunction(argv, n)
}

janet_get_cfunction :: proc(argv: ^Janet, n: i32) -> JanetCFunction {
	return _janet_getcfunction(argv, n)
}

janet_get_pointer :: proc(argv: ^Janet, n: i32) -> rawptr {
	return _janet_getpointer(argv, n)
}

janet_get_abstract :: proc(argv: ^Janet, n: i32) -> JanetAbstract {
	return _janet_getabstract(argv, n)
}

janet_get_size :: proc(argv: ^Janet, n: i32) -> int {
	return int(_janet_getsize(argv, n))
}

janet_get_nat :: proc(argv: ^Janet, n: i32) -> i32 {
	return _janet_getnat(argv, n)
}

// Fiber stack manipulation

// janet_fiber_push - Push a value onto a fiber's stack
janet_fiber_push :: proc(fiber: ^JanetFiber, x: Janet) {
	_janet_fiber_push(fiber, x)
}

// janet_fiber_push2 - Push two values onto a fiber's stack
janet_fiber_push2 :: proc(fiber: ^JanetFiber, x: Janet, y: Janet) {
	_janet_fiber_push2(fiber, x, y)
}

// janet_fiber_push3 - Push three values onto a fiber's stack
janet_fiber_push3 :: proc(fiber: ^JanetFiber, x: Janet, y: Janet, z: Janet) {
	_janet_fiber_push3(fiber, x, y, z)
}

// janet_fiber_pushn - Push n values from an array onto a fiber's stack
janet_fiber_pushn :: proc(fiber: ^JanetFiber, arr: ^JanetArray, offset: i32, n: i32) {
	_janet_fiber_pushn(fiber, arr, offset, n)
}
