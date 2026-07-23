package janet

import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

// Stack accessors - get values from argc/argv in C function callbacks

janet_get_boolean :: proc(argv: [^]Janet, n: i32) -> bool {
	return _janet_getboolean(argv, n) != 0
}

janet_get_integer :: proc(argv: [^]Janet, n: i32) -> i32 {
	return _janet_getinteger(argv, n)
}

janet_get_integer64 :: proc(argv: [^]Janet, n: i32) -> i64 {
	return _janet_getinteger64(argv, n)
}

janet_get_number :: proc(argv: [^]Janet, n: i32) -> f64 {
	return _janet_getnumber(argv, n)
}

janet_get_string :: proc(argv: [^]Janet, n: i32) -> JanetString {
	return _janet_getstring(argv, n)
}

janet_get_cstring :: proc(argv: [^]Janet, n: i32) -> cstring {
	return _janet_getcstring(argv, n)
}

janet_get_symbol :: proc(argv: [^]Janet, n: i32) -> JanetSymbol {
	return _janet_getsymbol(argv, n)
}

janet_get_keyword :: proc(argv: [^]Janet, n: i32) -> JanetKeyword {
	return _janet_getkeyword(argv, n)
}

janet_get_array :: proc(argv: [^]Janet, n: i32) -> ^JanetArray {
	return _janet_getarray(argv, n)
}

janet_get_tuple :: proc(argv: [^]Janet, n: i32) -> JanetTuple {
	return _janet_gettuple(argv, n)
}

janet_get_table :: proc(argv: [^]Janet, n: i32) -> ^JanetTable {
	return _janet_gettable(argv, n)
}

janet_get_struct :: proc(argv: [^]Janet, n: i32) -> JanetStruct {
	return _janet_getstruct(argv, n)
}

janet_get_buffer :: proc(argv: [^]Janet, n: i32) -> ^JanetBuffer {
	return _janet_getbuffer(argv, n)
}

janet_get_fiber :: proc(argv: [^]Janet, n: i32) -> ^JanetFiber {
	return _janet_getfiber(argv, n)
}

janet_get_function :: proc(argv: [^]Janet, n: i32) -> ^JanetFunction {
	return _janet_getfunction(argv, n)
}

janet_get_cfunction :: proc(argv: [^]Janet, n: i32) -> JanetCFunction {
	return _janet_getcfunction(argv, n)
}

janet_get_pointer :: proc(argv: [^]Janet, n: i32) -> rawptr {
	return _janet_getpointer(argv, n)
}

janet_get_abstract :: proc(argv: [^]Janet, n: i32) -> JanetAbstract {
	return _janet_getabstract(argv, n)
}

janet_get_size :: proc(argv: [^]Janet, n: i32) -> int {
	return int(_janet_getsize(argv, n))
}

janet_get_nat :: proc(argv: [^]Janet, n: i32) -> i32 {
	return _janet_getnat(argv, n)
}

// Stack manipulation

// janet_push - Push a value onto the VM stack
janet_push :: proc(vm: ^JanetVM, x: Janet) {
	_janet_push(vm, x)
}

// janet_pop - Pop a value from the VM stack
janet_pop :: proc(vm: ^JanetVM) -> Janet {
	return _janet_pop(vm)
}

// janet_dup - Duplicate the top value on the stack
janet_dup :: proc(vm: ^JanetVM) {
	_janet_dup(vm)
}

// Stack peek - look at stack without popping
janet_peek :: proc(vm: ^JanetVM, relative: i32) -> Janet {
	return _janet_peek(vm, relative)
}

// Stack top index
janet_get_top :: proc(vm: ^JanetVM) -> i32 {
	return _janet_gettop(vm)
}

janet_set_top :: proc(vm: ^JanetVM, new_top: i32) {
	_janet_settop(vm, new_top)
}

foreign janet_lib {
	@(link_name = "janet_getboolean")
	_janet_getboolean :: proc(argv: [^]Janet, n: i32) -> c.int ---

	@(link_name = "janet_getinteger")
	_janet_getinteger :: proc(argv: [^]Janet, n: i32) -> i32 ---

	@(link_name = "janet_getinteger64")
	_janet_getinteger64 :: proc(argv: [^]Janet, n: i32) -> i64 ---

	@(link_name = "janet_getnumber")
	_janet_getnumber :: proc(argv: [^]Janet, n: i32) -> f64 ---

	@(link_name = "janet_getstring")
	_janet_getstring :: proc(argv: [^]Janet, n: i32) -> JanetString ---

	@(link_name = "janet_getcstring")
	_janet_getcstring :: proc(argv: [^]Janet, n: i32) -> cstring ---

	@(link_name = "janet_getsymbol")
	_janet_getsymbol :: proc(argv: [^]Janet, n: i32) -> JanetSymbol ---

	@(link_name = "janet_getkeyword")
	_janet_getkeyword :: proc(argv: [^]Janet, n: i32) -> JanetKeyword ---

	@(link_name = "janet_getarray")
	_janet_getarray :: proc(argv: [^]Janet, n: i32) -> ^JanetArray ---

	@(link_name = "janet_gettuple")
	_janet_gettuple :: proc(argv: [^]Janet, n: i32) -> JanetTuple ---

	@(link_name = "janet_gettable")
	_janet_gettable :: proc(argv: [^]Janet, n: i32) -> ^JanetTable ---

	@(link_name = "janet_getstruct")
	_janet_getstruct :: proc(argv: [^]Janet, n: i32) -> JanetStruct ---

	@(link_name = "janet_getbuffer")
	_janet_getbuffer :: proc(argv: [^]Janet, n: i32) -> ^JanetBuffer ---

	@(link_name = "janet_getfiber")
	_janet_getfiber :: proc(argv: [^]Janet, n: i32) -> ^JanetFiber ---

	@(link_name = "janet_getfunction")
	_janet_getfunction :: proc(argv: [^]Janet, n: i32) -> ^JanetFunction ---

	@(link_name = "janet_getcfunction")
	_janet_getcfunction :: proc(argv: [^]Janet, n: i32) -> JanetCFunction ---

	@(link_name = "janet_getpointer")
	_janet_getpointer :: proc(argv: [^]Janet, n: i32) -> rawptr ---

	@(link_name = "janet_getabstract")
	_janet_getabstract :: proc(argv: [^]Janet, n: i32) -> JanetAbstract ---

	@(link_name = "janet_getsize")
	_janet_getsize :: proc(argv: [^]Janet, n: i32) -> c.size_t ---

	@(link_name = "janet_getnat")
	_janet_getnat :: proc(argv: [^]Janet, n: i32) -> i32 ---

	@(link_name = "janet_push")
	_janet_push :: proc(vm: ^JanetVM, x: Janet) ---

	@(link_name = "janet_pop")
	_janet_pop :: proc(vm: ^JanetVM) -> Janet ---

	@(link_name = "janet_dup")
	_janet_dup :: proc(vm: ^JanetVM) ---

	@(link_name = "janet_peek")
	_janet_peek :: proc(vm: ^JanetVM, relative: i32) -> Janet ---

	@(link_name = "janet_gettop")
	_janet_gettop :: proc(vm: ^JanetVM) -> i32 ---

	@(link_name = "janet_settop")
	_janet_settop :: proc(vm: ^JanetVM, new_top: i32) ---
}
