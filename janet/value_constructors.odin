package janet

// Value constructors - build JanetValue from Odin-native types.
// These are trivial wrappers that construct the union variant.
// No Janet interaction happens here; these are pure Odin values.

janet_nil :: proc() -> JanetValue {
	return Nil{}
}

janet_bool :: proc(b: bool) -> JanetValue {
	return b
}

janet_integer :: proc(n: i64) -> JanetValue {
	return n
}

janet_float :: proc(n: f64) -> JanetValue {
	return n
}

janet_string :: proc(s: string) -> JanetValue {
	return s
}

janet_array :: proc(items: []JanetValue) -> JanetValue {
	return items
}

janet_table :: proc(pairs: map[string]JanetValue) -> JanetValue {
	return pairs
}
