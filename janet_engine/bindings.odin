package janet_engine

import janet "../janet"
import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

// janet_function attribute - marks a proc for Janet binding (metadata only)
janet_function :: struct {
}

// janet_register - Register a JanetCFunction directly with the engine
janet_register :: proc(eng: ^JanetEngine, name: cstring, fn: janet.JanetCFunction) -> bool {
	cf_val := janet.janet_wrap_cfunction(fn)
	// Create Janet string from C string and use as key
	name_janet := janet.janet_wrap_string(_janet_cstring(name))
	janet_table_put(eng.env, name_janet, cf_val)
	return true
}

// janet_unregister - Remove a function from the engine
janet_unregister :: proc(eng: ^JanetEngine, name: cstring) {
	name_janet := janet.janet_wrap_string(_janet_cstring(name))
	janet_table_put(eng.env, name_janet, janet.janet_wrap_nil())
}

// janet_lookup - Look up a value in the engine environment
janet_lookup :: proc(eng: ^JanetEngine, name: cstring) -> janet.Janet {
	name_janet := janet.janet_wrap_string(_janet_cstring(name))
	return janet_table_get(eng.env, name_janet)
}

foreign janet_lib {
	@(link_name = "janet_cstring")
	_janet_cstring :: proc(cstr: cstring) -> janet.JanetString ---
}
