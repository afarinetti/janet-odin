package janet_engine

import janet_low "../janet_low"
import "core:c"

// janet_function attribute - marks a proc for Janet binding (metadata only)
janet_function :: struct {
	name:    string,
	summary: string,
}

// janet_register - Register a JanetCFunction directly with the engine
janet_register :: proc(eng: ^JanetEngine, name: cstring, fn: janet_low.JanetCFunction) -> bool {
	cf_val := janet_low.janet_wrap_cfunction(fn)
	janet_low.janet_def(eng.env, name, cf_val, "")
	return true
}

// janet_unregister - Remove a function from the engine
janet_unregister :: proc(eng: ^JanetEngine, name: cstring) {
	key := janet_low.janet_wrap_symbol(janet_low.janet_csymbol(name))
	janet_table_put(eng.env, key, janet_low.janet_wrap_nil())
}

// janet_lookup - Look up a value in the engine environment
janet_lookup :: proc(eng: ^JanetEngine, name: cstring) -> janet_low.Janet {
	key := janet_low.janet_wrap_symbol(janet_low.janet_csymbol(name))
	return janet_table_get(eng.env, key)
}
