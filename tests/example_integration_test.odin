package janet_test

import janet_low "../janet_low"
import janet_engine "../janet_engine"
import "base:runtime"
import "core:fmt"
import "core:os"
import "core:testing"

// ============================================================================
// Mock Odin Functions - Registered with Janet for Testing
// ============================================================================

// Mock entity storage
test_entities: [dynamic]^janet_low.JanetTable
test_next_entity_id: i32 = 1
test_player_id: i32 = 0
test_player_state: ^janet_low.JanetTable

// Helper to create a mock entity table
mock_create_position :: proc(x: f64, y: f64) -> ^janet_low.JanetTable {
	pos := janet_low.janet_table(2)
	janet_low.janet_table_put(
		pos,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("x")),
		janet_low.janet_wrap_number(x),
	)
	janet_low.janet_table_put(
		pos,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("y")),
		janet_low.janet_wrap_number(y),
	)
	return pos
}

mock_create_entity :: proc(type_name: cstring, x: f64, y: f64) -> ^janet_low.JanetTable {
	entity := janet_low.janet_table(8)
	janet_low.janet_table_put(
		entity,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("id")),
		janet_low.janet_wrap_integer(test_next_entity_id),
	)
	janet_low.janet_table_put(
		entity,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("type")),
		janet_low.janet_wrap_symbol(janet_low.janet_csymbol(type_name)),
	)
	janet_low.janet_table_put(
		entity,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("position")),
		janet_low.janet_wrap_table(mock_create_position(x, y)),
	)
	janet_low.janet_table_put(
		entity,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("health")),
		janet_low.janet_wrap_number(100.0),
	)
	test_next_entity_id += 1
	return entity
}

// Odin C functions callable from Janet

odin_get_entity :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	id := janet_low.janet_get_integer(argv, 0)
	if id > 0 && id <= i32(len(test_entities)) {
		return janet_low.janet_wrap_table(test_entities[id - 1])
	}
	return janet_low.janet_wrap_nil()
}

odin_get_player_id :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_integer(test_player_id)
}

odin_get_player_state :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	if test_player_state != nil {
		return janet_low.janet_wrap_table(test_player_state)
	}
	return janet_low.janet_wrap_nil()
}

odin_spawn_entity :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	type_sym := janet_low.janet_get_symbol(argv, 0)
	type_cstr := cstring(type_sym)

	data := janet_low.janet_get_table(argv, 1)
	pos_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("position"))
	pos_val := janet_low.janet_table_get(data, pos_key)
	pos := janet_low.janet_unwrap_table(pos_val)

	x_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("x"))
	y_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("y"))
	x := janet_low.janet_unwrap_number(janet_low.janet_table_get(pos, x_key))
	y := janet_low.janet_unwrap_number(janet_low.janet_table_get(pos, y_key))

	entity := mock_create_entity(type_cstr, x, y)
	runtime.append_elem(&test_entities, entity)

	if type_cstr == "player" {
		test_player_id = i32(len(test_entities))
		test_player_state = entity
	}

	return janet_low.janet_wrap_integer(i32(len(test_entities)))
}

odin_apply_velocity :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	entity_id := janet_low.janet_get_integer(argv, 0)
	vx := janet_low.janet_get_number(argv, 1)
	vy := janet_low.janet_get_number(argv, 2)
	dt := janet_low.janet_get_number(argv, 3)

	if entity_id > 0 && entity_id <= i32(len(test_entities)) {
		entity := test_entities[entity_id - 1]
		pos_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("position"))
		pos_val := janet_low.janet_table_get(entity, pos_key)
		pos := janet_low.janet_unwrap_table(pos_val)

		x_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("x"))
		y_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("y"))

		old_x := janet_low.janet_unwrap_number(janet_low.janet_table_get(pos, x_key))
		old_y := janet_low.janet_unwrap_number(janet_low.janet_table_get(pos, y_key))

		janet_low.janet_table_put(pos, x_key, janet_low.janet_wrap_number(old_x + vx * dt))
		janet_low.janet_table_put(pos, y_key, janet_low.janet_wrap_number(old_y + vy * dt))
	}
	return janet_low.janet_wrap_nil()
}

odin_apply_damage :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	entity_id := janet_low.janet_get_integer(argv, 0)
	amount := janet_low.janet_get_number(argv, 1)

	if entity_id > 0 && entity_id <= i32(len(test_entities)) {
		entity := test_entities[entity_id - 1]
		health_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("health"))
		old_health := janet_low.janet_unwrap_number(janet_low.janet_table_get(entity, health_key))
		new_health := old_health - amount
		if new_health < 0.0 {
			new_health = 0.0
		}
		janet_low.janet_table_put(entity, health_key, janet_low.janet_wrap_number(new_health))
	}
	return janet_low.janet_wrap_nil()
}

odin_get_input :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	input := janet_low.janet_table(3)
	janet_low.janet_table_put(
		input,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("move-x")),
		janet_low.janet_wrap_number(1.0),
	)
	janet_low.janet_table_put(
		input,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("move-y")),
		janet_low.janet_wrap_number(0.0),
	)
	janet_low.janet_table_put(
		input,
		janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("action")),
		janet_low.janet_wrap_nil(),
	)
	return janet_low.janet_wrap_table(input)
}

odin_set_flag :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_play_sound :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_animation :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_add_particle :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_give_xp :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_give_item :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_unlock_location :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_get_nearest_enemy :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_apply_effect :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_player_position :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_player_health :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_player_mana :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_inventory :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_equipment :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_set_player_stats :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_add_to_inventory :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_restore_entity :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_save_game :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_load_game :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_delete_save :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	return janet_low.janet_wrap_nil()
}

odin_get_save_slots :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	context = runtime.default_context()
	slots := janet_low.janet_array(3)
	janet_low.janet_array_push(slots, janet_low.janet_wrap_integer(1))
	janet_low.janet_array_push(slots, janet_low.janet_wrap_integer(2))
	janet_low.janet_array_push(slots, janet_low.janet_wrap_integer(3))
	return janet_low.janet_wrap_array(slots)
}

// ============================================================================
// Helper to Load and Register Example Scripts
// ============================================================================

load_example :: proc(eng: ^janet_engine.JanetEngine, filename: cstring) -> bool {
	data, err := os.read_entire_file_from_path(string(filename), context.allocator)
	if err != nil {
		return false
	}
	defer delete(data)

	out: janet_low.Janet
	status := janet_low.janet_dobytes(eng.env, raw_data(data), i32(len(data)), filename, &out)
	return status == 0
}

register_all_odin_functions :: proc(eng: ^janet_engine.JanetEngine) {
	janet_engine.janet_register(eng, "odin_get_entity", odin_get_entity)
	janet_engine.janet_register(eng, "odin_get_player_id", odin_get_player_id)
	janet_engine.janet_register(eng, "odin_get_player_state", odin_get_player_state)
	janet_engine.janet_register(eng, "odin_spawn_entity", odin_spawn_entity)
	janet_engine.janet_register(eng, "odin_apply_velocity", odin_apply_velocity)
	janet_engine.janet_register(eng, "odin_apply_damage", odin_apply_damage)
	janet_engine.janet_register(eng, "odin_get_input", odin_get_input)
	janet_engine.janet_register(eng, "odin_set_flag", odin_set_flag)
	janet_engine.janet_register(eng, "odin_play_sound", odin_play_sound)
	janet_engine.janet_register(eng, "odin_set_animation", odin_set_animation)
	janet_engine.janet_register(eng, "odin_add_particle", odin_add_particle)
	janet_engine.janet_register(eng, "odin_give_xp", odin_give_xp)
	janet_engine.janet_register(eng, "odin_give_item", odin_give_item)
	janet_engine.janet_register(eng, "odin_unlock_location", odin_unlock_location)
	janet_engine.janet_register(eng, "odin_get_nearest_enemy", odin_get_nearest_enemy)
	janet_engine.janet_register(eng, "odin_apply_effect", odin_apply_effect)
	janet_engine.janet_register(eng, "odin_set_player_position", odin_set_player_position)
	janet_engine.janet_register(eng, "odin_set_player_health", odin_set_player_health)
	janet_engine.janet_register(eng, "odin_set_player_mana", odin_set_player_mana)
	janet_engine.janet_register(eng, "odin_set_inventory", odin_set_inventory)
	janet_engine.janet_register(eng, "odin_set_equipment", odin_set_equipment)
	janet_engine.janet_register(eng, "odin_set_player_stats", odin_set_player_stats)
	janet_engine.janet_register(eng, "odin_add_to_inventory", odin_add_to_inventory)
	janet_engine.janet_register(eng, "odin_restore_entity", odin_restore_entity)
	janet_engine.janet_register(eng, "odin_save_game", odin_save_game)
	janet_engine.janet_register(eng, "odin_load_game", odin_load_game)
	janet_engine.janet_register(eng, "odin_delete_save", odin_delete_save)
	janet_engine.janet_register(eng, "odin_get_save_slots", odin_get_save_slots)
}

reset_test_state :: proc() {
	test_entities = [dynamic]^janet_low.JanetTable{}
	test_next_entity_id = 1
	test_player_id = 0
	test_player_state = nil
}

// ============================================================================
// Integration Tests
// ============================================================================

@(test)
test_ecs_behavior_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/ecs_behavior.janet")
	assert(ok, "failed to load ecs_behavior.janet")

	out: janet_low.Janet
	status := janet_low.janet_dostring(
		eng.env,
		"(odin_spawn_entity 'player @{:position @{:x 0.0 :y 0.0} :health 100})",
		"test",
		&out,
	)
	assert(status == 0, "spawn player failed")
	assert(janet_low.janet_type(out) == .NUMBER, "expected number")
	pid := janet_low.janet_unwrap_integer(out)
	assert(pid > 0, "expected valid entity id")

	status = janet_low.janet_dostring(eng.env, "(update-player 1 0.016)", "test", &out)
	assert(status == 0, "update-player failed")

	status = janet_low.janet_dostring(eng.env, "(odin_get_entity 1)", "test", &out)
	assert(status == 0, "get entity failed")
	entity := janet_low.janet_unwrap_table(out)
	pos_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("position"))
	pos := janet_low.janet_unwrap_table(janet_low.janet_table_get(entity, pos_key))
	x_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("x"))
	x := janet_low.janet_unwrap_number(janet_low.janet_table_get(pos, x_key))
	assert(x > 0.0, "player should have moved right")

	fmt.println("  ECS behavior: player movement works")
}

@(test)
test_event_system_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/event_system.janet")
	assert(ok, "failed to load event_system.janet")

	out: janet_low.Janet
	janet_low.janet_dostring(
		eng.env,
		"(odin_spawn_entity 'player @{:position @{:x 0.0 :y 0.0} :health 100})",
		"test",
		&out,
	)

	status := janet_low.janet_dostring(
		eng.env,
		"(handle-event :player-damage @{:amount 10 :source 2 :player 1})",
		"test",
		&out,
	)
	assert(status == 0, "handle-event failed")
	assert(janet_low.janet_truthy(out), "event should be handled")

	fmt.println("  Event system: dispatch and handling works")
}

@(test)
test_quest_system_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/quest_system.janet")
	assert(ok, "failed to load quest_system.janet")

	out: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, "(get-quest-info :lost-sword)", "test", &out)
	assert(status == 0, "get-quest-info failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected table")

	info := janet_low.janet_unwrap_table(out)
	name_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("name"))
	name_val := janet_low.janet_table_get(info, name_key)
	assert(janet_low.janet_type(name_val) == .STRING, "expected string name")

	fmt.println("  Quest system: quest definitions load correctly")
}

@(test)
test_inventory_system_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/inventory_system.janet")
	assert(ok, "failed to load inventory_system.janet")

	out: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, "(get-item-info :health-potion)", "test", &out)
	assert(status == 0, "get-item-info failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected table")

	fmt.println("  Inventory system: item definitions load correctly")
}

@(test)
test_dialogue_system_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/dialogue_system.janet")
	assert(ok, "failed to load dialogue_system.janet")

	out: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, "(get-dialogue :blacksmith-intro)", "test", &out)
	assert(status == 0, "get-dialogue failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected table")

	fmt.println("  Dialogue system: dialogue trees load correctly")
}

@(test)
test_ai_behavior_tree_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/ai_behavior_tree.janet")
	assert(ok, "failed to load ai_behavior_tree.janet")

	out: janet_low.Janet
	janet_low.janet_dostring(
		eng.env,
		"(odin_spawn_entity 'enemy @{:position @{:x 10.0 :y 10.0} :health 50})",
		"test",
		&out,
	)
	janet_low.janet_dostring(
		eng.env,
		"(odin_spawn_entity 'player @{:position @{:x 0.0 :y 0.0} :health 100})",
		"test",
		&out,
	)

	status := janet_low.janet_dostring(eng.env, "(evaluate-behavior-tree 1)", "test", &out)
	assert(status == 0, "evaluate-behavior-tree failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected table result")

	fmt.println("  AI behavior tree: evaluation works")
}

@(test)
test_combat_system_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/combat_system.janet")
	assert(ok, "failed to load combat_system.janet")

	out: janet_low.Janet
	janet_low.janet_dostring(
		eng.env,
		"(odin_spawn_entity 'player @{:position @{:x 0.0 :y 0.0} :health 100 :stats @{:attack 15 :defense 5 :armor 2}})",
		"test",
		&out,
	)
	janet_low.janet_dostring(
		eng.env,
		"(odin_spawn_entity 'enemy @{:position @{:x 5.0 :y 0.0} :health 50 :stats @{:attack 10 :defense 3 :armor 1}})",
		"test",
		&out,
	)

	status := janet_low.janet_dostring(eng.env, "(calculate-damage 1 2 :normal)", "test", &out)
	assert(status == 0, "calculate-damage failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected damage table")

	damage_table := janet_low.janet_unwrap_table(out)
	dmg_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("damage"))
	damage_val := janet_low.janet_table_get(damage_table, dmg_key)
	assert(janet_low.janet_type(damage_val) == .NUMBER, "expected number damage")
	damage := janet_low.janet_unwrap_number(damage_val)
	assert(damage > 0.0, "damage should be positive")

	fmt.println("  Combat system: damage calculation works")
}

@(test)
test_save_system_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/save_system.janet")
	assert(ok, "failed to load save_system.janet")

	out: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, "(get-save-info 1)", "test", &out)
	assert(status == 0, "get-save-info failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected table")

	fmt.println("  Save system: save slot queries work")
}

@(test)
test_main_game_example :: proc(t: ^testing.T) {
	reset_test_state()
	eng, ok := janet_engine.janet_engine_init({})
	assert(ok, "engine init failed")
	defer janet_engine.janet_engine_deinit(eng)

	register_all_odin_functions(eng)

	ok = load_example(eng, "examples/ecs_behavior.janet")
	assert(ok, "failed to load ecs_behavior.janet")
	ok = load_example(eng, "examples/event_system.janet")
	assert(ok, "failed to load event_system.janet")
	ok = load_example(eng, "examples/quest_system.janet")
	assert(ok, "failed to load quest_system.janet")
	ok = load_example(eng, "examples/inventory_system.janet")
	assert(ok, "failed to load inventory_system.janet")
	ok = load_example(eng, "examples/dialogue_system.janet")
	assert(ok, "failed to load dialogue_system.janet")
	ok = load_example(eng, "examples/ai_behavior_tree.janet")
	assert(ok, "failed to load ai_behavior_tree.janet")
	ok = load_example(eng, "examples/combat_system.janet")
	assert(ok, "failed to load combat_system.janet")
	ok = load_example(eng, "examples/save_system.janet")
	assert(ok, "failed to load save_system.janet")

	ok = load_example(eng, "examples/main_game.janet")
	assert(ok, "failed to load main_game.janet")

	out: janet_low.Janet
	status := janet_low.janet_dostring(eng.env, "(game-init)", "test", &out)
	assert(status == 0, "game-init failed")

	status = janet_low.janet_dostring(eng.env, "(game-update 0.016)", "test", &out)
	assert(status == 0, "game-update failed")

	status = janet_low.janet_dostring(eng.env, "(get-game-state)", "test", &out)
	assert(status == 0, "get-game-state failed")
	assert(janet_low.janet_type(out) == .TABLE, "expected game state table")

	state := janet_low.janet_unwrap_table(out)
	running_key := janet_low.janet_wrap_keyword(janet_low.janet_ckeyword("running"))
	running_val := janet_low.janet_table_get(state, running_key)
	assert(janet_low.janet_truthy(running_val), "game should be running")

	fmt.println("  Main game: full initialization and update loop works")
}
