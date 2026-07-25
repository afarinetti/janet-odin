// Example: Loading and running Janet scripts from Odin using the high-level API
// Demonstrates how to embed Janet scripting in a game with Odin-native types

package main

import janet_low "../janet_low"
import janet_engine "../janet_engine"
import janet "../janet"
import "core:fmt"
import "core:os"


// Odin function that adds two numbers - simple example using high-level API
odin_add :: proc(args: []janet.JanetValue) -> janet.JanetValue {
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

// Odin function that processes entity data using high-level API
// Called from Janet ECS scripts - no manual Janet type manipulation needed
odin_process_entity :: proc(args: []janet.JanetValue) -> janet.JanetValue {
	if len(args) != 1 {
		return janet.janet_nil()
	}

	// Get entity table from Janet - automatically converted to Odin map
	entity, ok := janet.to_table(args[0])
	if !ok {
		return janet.janet_nil()
	}

	// Get position from entity
	pos_val, ok2 := entity["position"]
	if !ok2 {
		return janet.janet_nil()
	}

	pos, ok3 := janet.to_table(pos_val)
	if !ok3 {
		return janet.janet_nil()
	}

	// Get x coordinate
	x_val, ok4 := pos["x"]
	if !ok4 {
		return janet.janet_nil()
	}

	x, ok5 := janet.to_float(x_val)
	if !ok5 {
		return janet.janet_nil()
	}

	// Modify x (e.g., apply physics)
	new_x := x + 1.0

	// Create new position
	new_pos := make(map[string]janet.JanetValue)
	new_pos["x"] = janet.janet_float(new_x)

	// Update entity
	entity["position"] = janet.janet_table(new_pos)

	return janet.janet_table(entity)
}

// Odin function that logs a message - demonstrates string handling
odin_log :: proc(args: []janet.JanetValue) -> janet.JanetValue {
	if len(args) != 1 {
		return janet.janet_nil()
	}

	msg, ok := janet.to_string(args[0])
	if !ok {
		return janet.janet_nil()
	}

	fmt.println("[Janet]", msg)
	return janet.janet_nil()
}

main :: proc() {
	// Initialize Janet engine
	eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
	if !ok {
		fmt.println("Failed to initialize Janet engine")
		return
	}
	defer janet_engine.janet_engine_deinit(eng)

	// Register Odin functions with Janet using high-level API
	// No need for proc "c" or manual argument extraction!
	janet.register(eng, "odin-add", odin_add)
	janet.register(eng, "odin-process-entity", odin_process_entity)
	janet.register(eng, "odin-log", odin_log)

	// Evaluate Janet code directly
	result, err := janet.eval(eng, "(odin-add 10 20)")
	if err == janet.JanetError.NONE {
		if val, ok := janet.to_integer(result); ok {
			fmt.println("odin-add result:", val)
		}
	}

	// Create an entity using high-level API
	entity := make(map[string]janet.JanetValue)

	// Add position
	pos := make(map[string]janet.JanetValue)
	pos["x"] = janet.janet_float(10.0)
	pos["y"] = janet.janet_float(20.0)
	entity["position"] = janet.janet_table(pos)

	// Add velocity
	vel := make(map[string]janet.JanetValue)
	vel["x"] = janet.janet_float(5.0)
	vel["y"] = janet.janet_float(0.0)
	entity["velocity"] = janet.janet_table(vel)

	fmt.println("Entity created with position (10, 20) and velocity (5, 0)")

	// Load and run a Janet script
	script, file_err := os.read_entire_file_from_path(
		"examples/ecs_behavior.janet",
		context.allocator,
	)
	if file_err != nil {
		fmt.println("Failed to load script:", file_err)
		fmt.println("(This is expected if running from a different directory)")
		return
	}
	defer delete(script)

	// Execute the script using high-level eval
	eval_result, eval_err := janet.eval(eng, string(script))
	if eval_err != janet.JanetError.NONE {
		fmt.println("Script execution had errors (this is expected for demo scripts)")
	} else {
		fmt.println("Script loaded successfully")
	}

	fmt.println("In a real game, you would call Janet's update-player function here")
}
