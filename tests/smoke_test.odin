package janet_test

import janet "../janet/core"
import "core:fmt"
import "core:testing"

@(test)
smoke_init :: proc(t: ^testing.T) {
	assert(janet.janet_init() == 0, "janet_init failed")
	janet.janet_deinit()
	fmt.println("smoke_init passed")
}

@(test)
smoke_vm_alloc :: proc(t: ^testing.T) {
	assert(janet.janet_init() == 0, "janet_init failed")
	defer janet.janet_deinit()

	vm := janet.janet_vm_alloc()
	assert(vm != nil, "janet_vm_alloc returned nil")
	janet.janet_vm_free(vm)
	fmt.println("smoke_vm_alloc passed")
}
