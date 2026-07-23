package janet

import "core:c"

// JanetError - Error type for Janet operations
JanetError :: struct {
	msg:    cstring,
	source: cstring,
	line:   i32,
}

// janet_error_format - Format an error message from a Janet value
// Uses janet_to_string internally since Janet doesn't have a dedicated error formatter
janet_error_format :: proc(err: Janet) -> JanetString {
	return _janet_to_string(err)
}
