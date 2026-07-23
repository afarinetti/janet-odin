package janet

foreign import janet_lib {"../../libjanet.a", "system:c"}

foreign janet_lib {
	// VM lifecycle
	@(link_name = "janet_init")
	janet_init :: proc() -> i32 ---

	@(link_name = "janet_deinit")
	janet_deinit :: proc() ---

	@(link_name = "janet_vm_alloc")
	janet_vm_alloc :: proc() -> ^JanetVM ---

	@(link_name = "janet_vm_free")
	janet_vm_free :: proc(vm: ^JanetVM) ---

	@(link_name = "janet_local_vm")
	janet_local_vm :: proc() -> ^JanetVM ---

	@(link_name = "janet_vm_load")
	janet_vm_load :: proc(from: ^JanetVM) ---

	@(link_name = "janet_core_env")
	janet_core_env :: proc(replacements: ^JanetTable) -> ^JanetTable ---

	@(link_name = "janet_gc")
	janet_gc :: proc() ---
}
