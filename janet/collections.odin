package janet

import "core:c"
import "core:mem"

// Table operations
janet_table :: proc(capacity: i32) -> ^JanetTable {
	return _janet_table(capacity)
}

janet_table_get :: proc(t: ^JanetTable, key: Janet) -> Janet {
	return _janet_table_get(t, key)
}

janet_table_put :: proc(t: ^JanetTable, key: Janet, value: Janet) {
	_janet_table_put(t, key, value)
}

janet_table_remove :: proc(t: ^JanetTable, key: Janet) -> Janet {
	return _janet_table_remove(t, key)
}

janet_table_length :: proc(t: ^JanetTable) -> i32 {
	return _janet_tablen(t)
}

// Array operations
janet_array :: proc(capacity: i32) -> ^JanetArray {
	return _janet_array(capacity)
}

janet_array_get :: proc(a: ^JanetArray, index: i32) -> Janet {
	// Convert pointer to slice for safe indexing
	data_slice := mem.slice_ptr(a^.data, int(a^.count))
	return data_slice[index]
}

janet_array_push :: proc(a: ^JanetArray, value: Janet) {
	_janet_array_push(a, value)
}

janet_array_pop :: proc(a: ^JanetArray) -> Janet {
	return _janet_array_pop(a)
}

janet_array_length :: proc(a: ^JanetArray) -> i32 {
	return a^.count
}

// Foreign declarations are in janet.odin
