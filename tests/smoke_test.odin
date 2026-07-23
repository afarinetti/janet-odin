package janet_test

import janet "../janet"
import janet_engine "../janet_engine"
import "base:runtime"
import "core:fmt"
import "core:testing"

@(test)
test_all :: proc(t: ^testing.T) {
	context = runtime.default_context()

	// Initialize Janet once
	result := janet.janet_init()
	assert(result == 0, "janet_init failed")
	fmt.println("janet_init: ok")

	// Test engine init
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "janet_engine_init failed")
	fmt.println("engine init: ok")

	// Test register
	my_add :: proc "c" (argc: i32, argv: [^]janet.Janet) -> janet.Janet {
		context = runtime.default_context()
		x := janet.janet_get_integer(argv, 0)
		y := janet.janet_get_integer(argv, 1)
		return janet.janet_wrap_integer(x + y)
	}

	ok = janet_engine.janet_register(eng, "my_add", my_add)
	assert(ok, "janet_register failed")
	fmt.println("registered my_add")

	// Test value wrapping
	ival := janet.janet_wrap_integer(42)
	assert(janet.janet_unwrap_integer(ival) == 42, "integer wrap/unwrap failed")
	fmt.println("wrap/unwrap: ok")

	fmt.println("all tests passed")
}
