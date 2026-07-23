package janet

import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

// Type checking

// janet_type - Returns the type of a Janet value
janet_type :: proc(x: Janet) -> JanetType {
	return _janet_type(x)
}

// janet_checktype - Check if a Janet value is of a specific type
janet_checktype :: proc(x: Janet, t: JanetType) -> bool {
	return _janet_checktype(x, t) != 0
}

// janet_truthy - Check if a Janet value is truthy
janet_truthy :: proc(x: Janet) -> bool {
	return _janet_truthy(x) != 0
}

// Wrap functions - convert Odin types to Janet values

janet_wrap_nil :: proc() -> Janet {
	return _janet_wrap_nil()
}

janet_wrap_true :: proc() -> Janet {
	return _janet_wrap_true()
}

janet_wrap_false :: proc() -> Janet {
	return _janet_wrap_false()
}

janet_wrap_boolean :: proc(x: bool) -> Janet {
	return _janet_wrap_boolean(x ? 1 : 0)
}

janet_wrap_number :: proc(x: f64) -> Janet {
	return _janet_wrap_number(x)
}

// janet_wrap_integer - wraps i32 as a Janet number
// Note: Janet uses janet_wrap_number internally for integers
janet_wrap_integer :: proc(x: i32) -> Janet {
	return _janet_wrap_number(f64(x))
}

janet_wrap_string :: proc(x: JanetString) -> Janet {
	return _janet_wrap_string(x)
}

janet_wrap_symbol :: proc(x: JanetSymbol) -> Janet {
	return _janet_wrap_symbol(x)
}

janet_wrap_keyword :: proc(x: JanetKeyword) -> Janet {
	return _janet_wrap_keyword(x)
}

janet_wrap_array :: proc(x: ^JanetArray) -> Janet {
	return _janet_wrap_array(x)
}

janet_wrap_tuple :: proc(x: JanetTuple) -> Janet {
	return _janet_wrap_tuple(x)
}

janet_wrap_struct :: proc(x: JanetStruct) -> Janet {
	return _janet_wrap_struct(x)
}

janet_wrap_fiber :: proc(x: ^JanetFiber) -> Janet {
	return _janet_wrap_fiber(x)
}

janet_wrap_buffer :: proc(x: ^JanetBuffer) -> Janet {
	return _janet_wrap_buffer(x)
}

janet_wrap_function :: proc(x: ^JanetFunction) -> Janet {
	return _janet_wrap_function(x)
}

janet_wrap_cfunction :: proc(x: JanetCFunction) -> Janet {
	return _janet_wrap_cfunction(x)
}

janet_wrap_table :: proc(x: ^JanetTable) -> Janet {
	return _janet_wrap_table(x)
}

janet_wrap_abstract :: proc(x: JanetAbstract) -> Janet {
	return _janet_wrap_abstract(x)
}

janet_wrap_pointer :: proc(x: rawptr) -> Janet {
	return _janet_wrap_pointer(x)
}

// Unwrap functions - convert Janet values to Odin types

janet_unwrap_boolean :: proc(x: Janet) -> bool {
	return _janet_unwrap_boolean(x) != 0
}

janet_unwrap_number :: proc(x: Janet) -> f64 {
	return _janet_unwrap_number(x)
}

// janet_unwrap_integer - unwraps a Janet number as i32
janet_unwrap_integer :: proc(x: Janet) -> i32 {
	return i32(_janet_unwrap_number(x))
}

janet_unwrap_string :: proc(x: Janet) -> JanetString {
	return _janet_unwrap_string(x)
}

janet_unwrap_symbol :: proc(x: Janet) -> JanetSymbol {
	return _janet_unwrap_symbol(x)
}

janet_unwrap_keyword :: proc(x: Janet) -> JanetKeyword {
	return _janet_unwrap_keyword(x)
}

janet_unwrap_array :: proc(x: Janet) -> ^JanetArray {
	return _janet_unwrap_array(x)
}

janet_unwrap_tuple :: proc(x: Janet) -> JanetTuple {
	return _janet_unwrap_tuple(x)
}

janet_unwrap_struct :: proc(x: Janet) -> JanetStruct {
	return _janet_unwrap_struct(x)
}

janet_unwrap_fiber :: proc(x: Janet) -> ^JanetFiber {
	return _janet_unwrap_fiber(x)
}

janet_unwrap_buffer :: proc(x: Janet) -> ^JanetBuffer {
	return _janet_unwrap_buffer(x)
}

janet_unwrap_function :: proc(x: Janet) -> ^JanetFunction {
	return _janet_unwrap_function(x)
}

janet_unwrap_cfunction :: proc(x: Janet) -> JanetCFunction {
	return _janet_unwrap_cfunction(x)
}

janet_unwrap_table :: proc(x: Janet) -> ^JanetTable {
	return _janet_unwrap_table(x)
}

janet_unwrap_abstract :: proc(x: Janet) -> JanetAbstract {
	return _janet_unwrap_abstract(x)
}

janet_unwrap_pointer :: proc(x: Janet) -> rawptr {
	return _janet_unwrap_pointer(x)
}

// Foreign imports
foreign janet_lib {
	@(link_name = "janet_type")
	_janet_type :: proc(x: Janet) -> JanetType ---

	@(link_name = "janet_checktype")
	_janet_checktype :: proc(x: Janet, t: JanetType) -> c.int ---

	@(link_name = "janet_truthy")
	_janet_truthy :: proc(x: Janet) -> c.int ---

	@(link_name = "janet_wrap_nil")
	_janet_wrap_nil :: proc() -> Janet ---

	@(link_name = "janet_wrap_true")
	_janet_wrap_true :: proc() -> Janet ---

	@(link_name = "janet_wrap_false")
	_janet_wrap_false :: proc() -> Janet ---

	@(link_name = "janet_wrap_boolean")
	_janet_wrap_boolean :: proc(x: c.int) -> Janet ---

	@(link_name = "janet_wrap_number")
	_janet_wrap_number :: proc(x: f64) -> Janet ---

	@(link_name = "janet_wrap_string")
	_janet_wrap_string :: proc(x: JanetString) -> Janet ---

	@(link_name = "janet_wrap_symbol")
	_janet_wrap_symbol :: proc(x: JanetSymbol) -> Janet ---

	@(link_name = "janet_wrap_keyword")
	_janet_wrap_keyword :: proc(x: JanetKeyword) -> Janet ---

	@(link_name = "janet_wrap_array")
	_janet_wrap_array :: proc(x: ^JanetArray) -> Janet ---

	@(link_name = "janet_wrap_tuple")
	_janet_wrap_tuple :: proc(x: JanetTuple) -> Janet ---

	@(link_name = "janet_wrap_struct")
	_janet_wrap_struct :: proc(x: JanetStruct) -> Janet ---

	@(link_name = "janet_wrap_fiber")
	_janet_wrap_fiber :: proc(x: ^JanetFiber) -> Janet ---

	@(link_name = "janet_wrap_buffer")
	_janet_wrap_buffer :: proc(x: ^JanetBuffer) -> Janet ---

	@(link_name = "janet_wrap_function")
	_janet_wrap_function :: proc(x: ^JanetFunction) -> Janet ---

	@(link_name = "janet_wrap_cfunction")
	_janet_wrap_cfunction :: proc(x: JanetCFunction) -> Janet ---

	@(link_name = "janet_wrap_table")
	_janet_wrap_table :: proc(x: ^JanetTable) -> Janet ---

	@(link_name = "janet_wrap_abstract")
	_janet_wrap_abstract :: proc(x: JanetAbstract) -> Janet ---

	@(link_name = "janet_wrap_pointer")
	_janet_wrap_pointer :: proc(x: rawptr) -> Janet ---

	@(link_name = "janet_unwrap_boolean")
	_janet_unwrap_boolean :: proc(x: Janet) -> c.int ---

	@(link_name = "janet_unwrap_number")
	_janet_unwrap_number :: proc(x: Janet) -> f64 ---

	@(link_name = "janet_unwrap_string")
	_janet_unwrap_string :: proc(x: Janet) -> JanetString ---

	@(link_name = "janet_unwrap_symbol")
	_janet_unwrap_symbol :: proc(x: Janet) -> JanetSymbol ---

	@(link_name = "janet_unwrap_keyword")
	_janet_unwrap_keyword :: proc(x: Janet) -> JanetKeyword ---

	@(link_name = "janet_unwrap_array")
	_janet_unwrap_array :: proc(x: Janet) -> ^JanetArray ---

	@(link_name = "janet_unwrap_tuple")
	_janet_unwrap_tuple :: proc(x: Janet) -> JanetTuple ---

	@(link_name = "janet_unwrap_struct")
	_janet_unwrap_struct :: proc(x: Janet) -> JanetStruct ---

	@(link_name = "janet_unwrap_fiber")
	_janet_unwrap_fiber :: proc(x: Janet) -> ^JanetFiber ---

	@(link_name = "janet_unwrap_buffer")
	_janet_unwrap_buffer :: proc(x: Janet) -> ^JanetBuffer ---

	@(link_name = "janet_unwrap_function")
	_janet_unwrap_function :: proc(x: Janet) -> ^JanetFunction ---

	@(link_name = "janet_unwrap_cfunction")
	_janet_unwrap_cfunction :: proc(x: Janet) -> JanetCFunction ---

	@(link_name = "janet_unwrap_table")
	_janet_unwrap_table :: proc(x: Janet) -> ^JanetTable ---

	@(link_name = "janet_unwrap_abstract")
	_janet_unwrap_abstract :: proc(x: Janet) -> JanetAbstract ---

	@(link_name = "janet_unwrap_pointer")
	_janet_unwrap_pointer :: proc(x: Janet) -> rawptr ---
}
