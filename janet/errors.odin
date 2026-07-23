package janet

import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

// JanetError - Error type for Janet operations
JanetError :: struct {
	msg:    cstring,
	source: cstring,
	line:   i32,
}

// janet_error_format - Format an error message from a Janet value
janet_error_format :: proc(err: Janet) -> cstring {
	return _janet_error_format(err)
}

foreign janet_lib {
	@(link_name = "janet_error_format")
	_janet_error_format :: proc(err: Janet) -> cstring ---
}
