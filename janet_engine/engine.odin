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
	boot_script: cstring,
}

// janet_engine_init - Initialize a new Janet engine
janet_engine_init :: proc(cfg: EngineConfig) -> (^JanetEngine, bool) {
	// Initialize Janet if not already initialized
	janet.janet_init()

	// Allocate VM
	vm := janet.janet_vm_alloc()
	if vm == nil {
		return nil, false
	}

	// Load VM with environment
	janet.janet_vm_load(vm)

	// Get the core environment
	env := janet.janet_core_env(nil)
	if env == nil {
		janet.janet_vm_free(vm)
		return nil, false
	}

	// Create engine
	eng := new(JanetEngine)
	eng.vm = vm
	eng.env = env
	eng.boot_script = cfg.boot_script

	return eng, true
}

// janet_engine_deinit - Shutdown a Janet engine
janet_engine_deinit :: proc(eng: ^JanetEngine) {
	if eng != nil {
		if eng.vm != nil {
			janet.janet_vm_free(eng.vm)
		}
		free(eng)
	}
}
