package janet

import "core:c"

// Type checking

// janet_type - Returns the type of a Janet value
janet_type :: proc(x: Janet) -> JanetType {
	return _janet_type(x)
}

// janet_checktype - Check if a Janet value is of a specific type
janet_checktype :: proc(x: Janet, t: JanetType) -> bool {
	return _janet_checktype(x, t) != 0
}

// janet_checktypes - Check if a Janet value matches any of the given type flags
janet_checktypes :: proc(x: Janet, typeflags: int) -> bool {
	return _janet_checktypes(x, c.int(typeflags)) != 0
}

// janet_truthy - Check if a Janet value is truthy
janet_truthy :: proc(x: Janet) -> bool {
	return _janet_truthy(x) != 0
}

// Wrap functions - convert Odin types to Janet values
// On ARM64 (non-nanbox), Janet is a struct {union as; JanetType type}

janet_wrap_nil :: proc() -> Janet {
	result: Janet
	result.as.u64 = 0
	result.type = JanetType.NIL
	return result
}

janet_wrap_true :: proc() -> Janet {
	result: Janet
	result.as.u64 = 1
	result.type = JanetType.BOOLEAN
	return result
}

janet_wrap_false :: proc() -> Janet {
	result: Janet
	result.as.u64 = 0
	result.type = JanetType.BOOLEAN
	return result
}

janet_wrap_boolean :: proc(x: bool) -> Janet {
	result: Janet
	result.as.u64 = x ? 1 : 0
	result.type = JanetType.BOOLEAN
	return result
}

// janet_wrap_integer - wraps i32 as a Janet number
janet_wrap_integer :: proc(x: i32) -> Janet {
	result: Janet
	result.as.number = f64(x)
	result.type = JanetType.NUMBER
	return result
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
	return _janet_unwrap_integer(x)
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

// GC root management

// janet_gcroot - Register a Janet value as a GC root
janet_gcroot :: proc(root: Janet) {
	_janet_gcroot(root)
}

// janet_gcunroot - Unregister a Janet value as a GC root
janet_gcunroot :: proc(root: Janet) -> bool {
	return _janet_gcunroot(root) != 0
}

// janet_gcunrootall - Unregister all instances of a Janet value as GC roots
janet_gcunrootall :: proc(root: Janet) -> bool {
	return _janet_gcunrootall(root) != 0
}

// janet_gclock - Lock the GC to prevent collection
janet_gclock :: proc() -> i32 {
	return i32(_janet_gclock())
}

// janet_gcunlock - Unlock the GC
janet_gcunlock :: proc(handle: i32) {
	_janet_gcunlock(c.int(handle))
}

// janet_gcpressure - Inform GC about external memory pressure
janet_gcpressure :: proc(s: int) {
	_janet_gcpressure(c.size_t(s))
}

// janet_collect - Force a garbage collection cycle
janet_collect :: proc() {
	_janet_collect()
}

// janet_wrap_integer64 - wraps i64 as a Janet number
janet_wrap_integer64 :: proc(x: i64) -> Janet {
	result: Janet
	result.as.number = f64(x)
	result.type = JanetType.NUMBER
	return result
}

// janet_wrap_number - wraps f64 as a Janet number
janet_wrap_number :: proc(x: f64) -> Janet {
	result: Janet
	result.as.number = x
	result.type = JanetType.NUMBER
	return result
}

// janet_unwrap_integer64 - unwraps a Janet number as i64
janet_unwrap_integer64 :: proc(x: Janet) -> i64 {
	return i64(_janet_unwrap_number(x))
}

// String creation helpers
janet_cstring :: proc(s: cstring) -> JanetString {
	return _janet_cstring(s)
}

janet_csymbol :: proc(s: cstring) -> JanetSymbol {
	return _janet_csymbol(s)
}

janet_ckeyword :: proc(s: cstring) -> JanetKeyword {
	return JanetKeyword(_janet_csymbol(s))
}
