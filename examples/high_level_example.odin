package main

import janet_low "../janet_low"
import janet_engine "../janet_engine"
import janet "../janet"
import "core:fmt"

main :: proc() {
	// Initialize Janet engine
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	if !ok {
		fmt.println("Failed to initialize Janet engine")
		return
	}
	defer janet_engine.janet_engine_deinit(eng)

	fmt.println("=== Janet High-Level API Example ===\n")

	// Example 1: Register a simple function
	fmt.println("1. Registering and calling a simple function:")
	add_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		if len(args) != 2 {
			return janet.janet_nil()
		}

		a, ok1 := janet.to_integer(args[0])
		b, ok2 := janet.to_integer(args[1])

		if !ok1 || !ok2 {
			return janet.janet_nil()
		}

		return janet.janet_integer(a + b)
	}

	janet.register(eng, "add", add_fn)

	// Call the function from Janet code
	result, err := janet.eval(eng, "(add 5 3)")
	if err != janet.JanetError.NONE {
		fmt.println("Error:", err)
	} else {
		if val, ok := janet.to_integer(result); ok {
			fmt.println("   (add 5 3) =", val)
		}
	}

	// Example 2: Work with strings
	fmt.println("\n2. String operations:")
	greet_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		if len(args) != 1 {
			return janet.janet_nil()
		}

		name, ok := janet.to_string(args[0])
		if !ok {
			return janet.janet_nil()
		}

		greeting := fmt.tprintf("Hello, %s!", name)
		return janet.janet_string(greeting)
	}

	janet.register(eng, "greet", greet_fn)

	result, err = janet.eval(eng, `(greet "World")`)
	if err != janet.JanetError.NONE {
		fmt.println("Error:", err)
	} else {
		if val, ok := janet.to_string(result); ok {
			fmt.println("   (greet \"World\") =", val)
		}
	}

	// Example 3: Work with arrays
	fmt.println("\n3. Array operations:")
	sum_array_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		if len(args) != 1 {
			return janet.janet_nil()
		}

		arr, ok := janet.to_array(args[0])
		if !ok {
			return janet.janet_nil()
		}

		sum: i64 = 0
		for elem in arr {
			if val, ok := janet.to_integer(elem); ok {
				sum += val
			}
		}

		return janet.janet_integer(sum)
	}

	janet.register(eng, "sum-array", sum_array_fn)

	result, err = janet.eval(eng, "(sum-array @[1 2 3 4 5])")
	if err != janet.JanetError.NONE {
		fmt.println("Error:", err)
	} else {
		if val, ok := janet.to_integer(result); ok {
			fmt.println("   (sum-array @[1 2 3 4 5]) =", val)
		}
	}

	// Example 4: Work with tables
	fmt.println("\n4. Table operations:")
	get_value_fn :: proc(args: []janet.JanetValue) -> janet.JanetValue {
		if len(args) != 2 {
			return janet.janet_nil()
		}

		tbl, ok1 := janet.to_table(args[0])
		key, ok2 := janet.to_string(args[1])

		if !ok1 || !ok2 {
			return janet.janet_nil()
		}

		if val, ok := tbl[key]; ok {
			return val
		}

		return janet.janet_nil()
	}

	janet.register(eng, "get-value", get_value_fn)

	result, err = janet.eval(eng, `(get-value {:name "Alice" :age 30} "name")`)
	if err != janet.JanetError.NONE {
		fmt.println("Error:", err)
	} else {
		if val, ok := janet.to_string(result); ok {
			fmt.println("   (get-value {:name \"Alice\" :age 30} \"name\") =", val)
		}
	}

	// Example 5: Create Janet values from Odin
	fmt.println("\n5. Creating Janet values from Odin:")

	// Create an array
	items := []janet.JanetValue {
		janet.janet_integer(10),
		janet.janet_integer(20),
		janet.janet_integer(30),
	}
	array_val := janet.janet_array(items)

	// Create a table
	pairs := make(map[string]janet.JanetValue)
	pairs["x"] = janet.janet_integer(100)
	pairs["y"] = janet.janet_integer(200)
	table_val := janet.janet_table(pairs)

	fmt.println("   Created array with", len(items), "elements")
	fmt.println("   Created table with", len(pairs), "entries")

	fmt.println("\n=== Example Complete ===")
}
