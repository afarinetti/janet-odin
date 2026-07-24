// Example: Loading and running Janet scripts from Odin
// Demonstrates how to embed Janet scripting in a game

package main

import (
	"fmt"
	"os"
	"../janet"
	"../janet_engine"
)

// Odin function callable from Janet
// Adds two numbers - simple example
odin_add :: proc "c" (argc: i32, argv: ^janet.Janet) -> janet.Janet {
	context = runtime.default_context()
	a := janet.janet_get_integer(argv, 0)
	b := janet.janet_get_integer(argv, 1)
	return janet.janet_wrap_integer(a + b)
}

// Odin function that processes entity data
// Called from Janet ECS scripts
odin_process_entity :: proc "c" (argc: i32, argv: ^janet.Janet) -> janet.Janet {
	context = runtime.default_context()
	
	// Get entity table from Janet
	entity := janet.janet_unwrap_table(argv[0])
	
	// Get position from entity
	pos_key := janet.janet_wrap_keyword(janet.janet_ckeyword("position"))
	pos_val := janet.janet_table_get(entity, pos_key)
	pos := janet.janet_unwrap_table(pos_val)
	
	// Get x coordinate
	x_key := janet.janet_wrap_keyword(janet.janet_ckeyword("x"))
	x_val := janet.janet_table_get(pos, x_key)
	x := janet.janet_unwrap_number(x_val)
	
	// Modify x (e.g., apply physics)
	new_x := x + 1.0
	
	// Create new position
	new_pos := janet.janet_table(2)
	janet.janet_table_put(new_pos, x_key, janet.janet_wrap_number(new_x))
	
	// Update entity
	janet.janet_table_put(entity, pos_key, janet.janet_wrap_table(new_pos))
	
	return janet.janet_wrap_table(entity)
}

main :: proc() {
	// Initialize Janet engine
	eng, ok := janet_engine.janet_engine_init({})
	if !ok {
		fmt.println("Failed to initialize Janet engine")
		return
	}
	defer janet_engine.janet_engine_deinit(eng)
	
	// Register Odin functions with Janet
	janet_engine.janet_register(eng, "odin_add", odin_add)
	janet_engine.janet_register(eng, "odin_process_entity", odin_process_entity)
	
	// Load and run a Janet script
	script, err := os.read_entire_file_from_path("examples/ecs_behavior.janet", context.allocator)
	if err != nil {
		fmt.println("Failed to load script:", err)
		return
	}
	defer delete(script)
	
	// Execute the script
	result, ok := janet_engine.janet_dobytes(eng, script, len(script), "ecs_behavior.janet")
	if !ok {
		fmt.println("Script execution failed")
		return
	}
	
	fmt.println("Script loaded successfully")
	
	// Now we can call Janet functions from Odin
	// For example, create an entity and update it
	entity := janet.janet_table(4)
	
	// Add position
	pos := janet.janet_table(2)
	janet.janet_table_put(pos, janet.janet_wrap_keyword(janet.janet_ckeyword("x")), janet.janet_wrap_number(10.0))
	janet.janet_table_put(pos, janet.janet_wrap_keyword(janet.janet_ckeyword("y")), janet.janet_wrap_number(20.0))
	janet.janet_table_put(entity, janet.janet_wrap_keyword(janet.janet_ckeyword("position")), janet.janet_wrap_table(pos))
	
	// Add velocity
	vel := janet.janet_table(2)
	janet.janet_table_put(vel, janet.janet_wrap_keyword(janet.janet_ckeyword("x")), janet.janet_wrap_number(5.0))
	janet.janet_table_put(vel, janet.janet_wrap_keyword(janet.janet_ckeyword("y")), janet.janet_wrap_number(0.0))
	janet.janet_table_put(entity, janet.janet_wrap_keyword(janet.janet_ckeyword("velocity")), janet.janet_wrap_table(vel))
	
	// Call Janet's update-player function
	// In a real game, this would be called in the game loop
	fmt.println("Entity created with position (10, 20) and velocity (5, 0)")
	fmt.println("In a real game, you would call Janet's update-player function here")
}
