package janet

// Value extractors - extract Odin-native types from JanetValue.
// Each returns (value, ok) where ok indicates whether the extraction succeeded.
// Uses Odin's union type assertions - no Janet type checking needed.

to_bool :: proc(v: JanetValue) -> (bool, bool) {
	if b, ok := v.(bool); ok {
		return b, true
	}
	return false, false
}

to_integer :: proc(v: JanetValue) -> (i64, bool) {
	if n, ok := v.(i64); ok {
		return n, true
	}
	return 0, false
}

to_float :: proc(v: JanetValue) -> (f64, bool) {
	if n, ok := v.(f64); ok {
		return n, true
	}
	return 0.0, false
}

to_string :: proc(v: JanetValue) -> (string, bool) {
	if s, ok := v.(string); ok {
		return s, true
	}
	return "", false
}

to_array :: proc(v: JanetValue) -> ([]JanetValue, bool) {
	if arr, ok := v.([]JanetValue); ok {
		return arr, true
	}
	return nil, false
}

to_table :: proc(v: JanetValue) -> (map[string]JanetValue, bool) {
	if tbl, ok := v.(map[string]JanetValue); ok {
		return tbl, true
	}
	return nil, false
}
