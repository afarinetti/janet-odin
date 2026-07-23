package janet_engine

import janet "../janet"
import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

// Engine configuration
EngineConfig :: struct {
	boot_script: cstring,
}

// JanetEngine - Main Janet engine instance
JanetEngine :: struct {
	env:         ^janet.JanetTable,
	boot_script: cstring,
}

// janet_engine_init - Initialize a new Janet engine
janet_engine_init :: proc(cfg: EngineConfig) -> (^JanetEngine, bool) {
	// Initialize Janet (process-global)
	janet.janet_init()

	// Get the current VM
	vm := janet.janet_local_vm()
	if vm == nil {
		return nil, false
	}

	// Get the core environment
	env := janet.janet_core_env(nil)
	if env == nil {
		return nil, false
	}

	// Create engine
	eng := new(JanetEngine)
	eng.env = env
	eng.boot_script = cfg.boot_script

	return eng, true
}

// janet_engine_deinit - Shutdown a Janet engine
janet_engine_deinit :: proc(eng: ^JanetEngine) {
	if eng != nil {
		free(eng)
	}
}

// Table operations
janet_table_put :: proc(t: ^janet.JanetTable, key: janet.Janet, val: janet.Janet) {
	_janet_table_put(t, key, val)
}

janet_table_get :: proc(t: ^janet.JanetTable, key: janet.Janet) -> janet.Janet {
	return _janet_table_get(t, key)
}

foreign janet_lib {
	@(link_name = "janet_table_put")
	_janet_table_put :: proc(t: ^janet.JanetTable, key: janet.Janet, val: janet.Janet) ---

	@(link_name = "janet_table_get")
	_janet_table_get :: proc(t: ^janet.JanetTable, key: janet.Janet) -> janet.Janet ---
}
