package janet_test

import janet "../janet"
import "core:fmt"
import "core:testing"

@(test)
smoke_init :: proc(t: ^testing.T) {
	result := janet.janet_init()
	assert(result == 0, "janet_init failed")
	janet.janet_deinit()
	fmt.println("smoke_init passed")
}

@(test)
smoke_vm_alloc :: proc(t: ^testing.T) {
	result := janet.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet.janet_deinit()

	vm := janet.janet_vm_alloc()
	assert(vm != nil, "janet_vm_alloc returned nil")
	janet.janet_vm_free(vm)
	fmt.println("smoke_vm_alloc passed")
}

@(test)
test_wrap_unwrap_integer :: proc(t: ^testing.T) {
	result := janet.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet.janet_deinit()

	val := janet.janet_wrap_integer(42)
	unwrapped := janet.janet_unwrap_integer(val)
	assert(unwrapped == 42, "integer wrap/unwrap failed")
	fmt.println("test_wrap_unwrap_integer passed")
}

@(test)
test_wrap_unwrap_boolean :: proc(t: ^testing.T) {
	result := janet.janet_init()
	assert(result == 0, "janet_init failed")
	defer janet.janet_deinit()

	true_val := janet.janet_wrap_boolean(true)
	false_val := janet.janet_wrap_boolean(false)
	assert(janet.janet_unwrap_boolean(true_val) == true, "boolean true unwrap failed")
	assert(janet.janet_unwrap_boolean(false_val) == false, "boolean false unwrap failed")
	fmt.println("test_wrap_unwrap_boolean passed")
}
