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
	vm:          ^janet.JanetVM,
	env:         ^janet.JanetTable,
	env_root:    janet.Janet, // GC-rooted copy of env as Janet value
	boot_script: cstring,
}

// janet_engine_init - Initialize a new Janet engine
janet_engine_init :: proc(cfg: EngineConfig) -> (^JanetEngine, bool) {
	// Initialize Janet (process-global, idempotent)
	// This sets up the global janet_vm directly.
	janet.janet_init()

	// Get the current thread-local VM (the one just initialized by janet_init)
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
	eng.vm = vm
	eng.env = env
	eng.boot_script = cfg.boot_script

	// GC root the environment table so it doesn't get collected
	eng.env_root = janet.janet_wrap_table(env)
	janet.janet_gcroot(eng.env_root)

	return eng, true
}

// janet_engine_deinit - Shutdown a Janet engine
// NOTE: janet_init() sets up a global thread-local VM, not one allocated
// via janet_vm_alloc(). We must NOT call janet_vm_free on it.
janet_engine_deinit :: proc(eng: ^JanetEngine) {
	if eng != nil {
		// Unroot the environment before teardown
		janet.janet_gcunroot(eng.env_root)
		// Do NOT call janet_vm_free - the VM belongs to janet_init's global state.
		// Only free VMs that were explicitly allocated via janet_vm_alloc.
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

janet_table_remove :: proc(t: ^janet.JanetTable, key: janet.Janet) -> janet.Janet {
	return _janet_table_remove(t, key)
}

foreign janet_lib {
	@(link_name = "janet_table_put")
	_janet_table_put :: proc(t: ^janet.JanetTable, key: janet.Janet, val: janet.Janet) ---

	@(link_name = "janet_table_get")
	_janet_table_get :: proc(t: ^janet.JanetTable, key: janet.Janet) -> janet.Janet ---

	@(link_name = "janet_table_remove")
	_janet_table_remove :: proc(t: ^janet.JanetTable, key: janet.Janet) -> janet.Janet ---
}
