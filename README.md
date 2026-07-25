# janet-odin

Odin bindings for the [Janet](https://janet-lang.org/) programming language.

## Overview

janet-odin provides three packages for embedding Janet in Odin applications:

- **`janet`** — High-level API with Odin-native types, automatic GC management, and ergonomic function registration. **Recommended for most use cases.**
- **`janet_low`** — Low-level FFI bindings to Janet's C API. Direct access to value types, type checking, environment operations, and evaluation functions.
- **`janet_engine`** — Engine wrapper that manages Janet VM instances, provides helper functions for code execution, and handles environment setup.

Janet is a dynamic, Lisp-like language with a focus on simplicity and embeddability. These bindings enable calling Janet code from Odin and vice versa.

## Requirements

- Odin >= 0.14.0
- C compiler (clang recommended)
- Meson and Ninja (for building Janet)

## Building

1. Build the vendored Janet library:

```bash
cd vendor/janet
meson setup build
ninja -C build
cp build/libjanet.a ..
```

2. Compile your Odin project:

```bash
odin build . -collection:janet-odin/janet=janet -collection:janet-odin/janet_engine=janet_engine
```

## Usage

### Basic Example
```odin
import janet "../janet"
import janet_engine "../janet_engine"

main :: proc() {
    // Initialize engine
    eng, ok := janet_engine.janet_engine_init({})
    if !ok {
        fmt.println("engine init failed")
        return
    }
    defer janet_engine.janet_engine_deinit(eng)

    // Evaluate Janet code and get result
    result, err := janet.eval(eng, "(+ 1 2 3)")
    if err == .NONE {
        if value, ok := janet.to_integer(result); ok {
            fmt.println("result:", value)  // prints: result: 6
        }
    }
}
```

### Registering Odin Functions

```odin
// Define a high-level function using Odin-native types
odin_add :: proc(args: []janet.JanetValue) -> janet.JanetValue {
    a, _ := janet.to_integer(args[0])
    b, _ := janet.to_integer(args[1])
    return janet.janet_integer(a + b)
}

// Register it with the engine
eng, _ := janet_engine.janet_engine_init({})
defer janet_engine.janet_engine_deinit(eng)

janet.register(eng, "odin-add", odin_add)

// Call from Janet
result, _ := janet.eval(eng, "(odin-add 10 20)")
// result == 30
```

### Passing Data Between Odin and Janet

```odin
// Create a Janet array from Odin using high-level API
items := []janet.JanetValue{
    janet.janet_integer(10),
    janet.janet_integer(20),
    janet.janet_integer(30),
}
data := janet.janet_array(items)

// Pass to Janet code
janet.janet_def(eng.env, "data", data, "")

result, _ := janet.eval(eng, "(length data)")
// result == 3
```

## API Reference

### janet Package (High-Level API)

**Recommended for most use cases.** Provides Odin-native types and automatic GC management.

#### Value Types

- `JanetValue` — Tagged union representing Janet values using Odin-native types (nil, bool, i64, f64, string, []JanetValue, map[string]JanetValue)
- `JanetError` — Error enum (NONE, COMPILE_ERROR, RUNTIME_ERROR, TYPE_ERROR, FILE_NOT_FOUND)
- `JanetResult` — Result struct containing value, error, and message

#### Value Construction (Odin → JanetValue)

- `janet_nil() -> JanetValue`
- `janet_bool(b: bool) -> JanetValue`
- `janet_integer(n: i64) -> JanetValue`
- `janet_float(n: f64) -> JanetValue`
- `janet_string(s: string) -> JanetValue`
- `janet_array(items: []JanetValue) -> JanetValue`
- `janet_table(pairs: map[string]JanetValue) -> JanetValue`

#### Value Extraction (JanetValue → Odin)

- `to_bool(v: JanetValue) -> (bool, bool)`
- `to_integer(v: JanetValue) -> (i64, bool)`
- `to_float(v: JanetValue) -> (f64, bool)`
- `to_string(v: JanetValue) -> (string, bool)`
- `to_array(v: JanetValue) -> ([]JanetValue, bool)`
- `to_table(v: JanetValue) -> (map[string]JanetValue, bool)`

#### Function Registration

- `HighLevelFn :: proc(args: []JanetValue) -> JanetValue`
- `register(eng: ^janet_engine.JanetEngine, name: string, fn: HighLevelFn) -> bool`
- `unregister(eng: ^janet_engine.JanetEngine, name: string)`

#### Evaluation

- `eval(eng: ^janet_engine.JanetEngine, code: string) -> (JanetValue, JanetError)`
- `eval_file(eng: ^janet_engine.JanetEngine, path: string) -> (JanetValue, JanetError)`
- `call(eng: ^janet_engine.JanetEngine, fn_name: string, args: []JanetValue) -> (JanetValue, JanetError)`

### janet_low Package (Low-Level API)

Direct FFI bindings to Janet's C API. Use when you need fine-grained control.

#### Value Types

- `Janet` — Core value type (tagged union)
- `JanetType` — Type enum (NIL, BOOLEAN, NUMBER, STRING, SYMBOL, KEYWORD, ARRAY, TUPLE, TABLE, STRUCT, BUFFER, FUNCTION, CFUNCTION, ABSTRACT, POINTER)
- `JanetString`, `JanetSymbol`, `JanetKeyword` — String-like types (distinct `^u8`)
- `JanetArray`, `JanetTable`, `JanetBuffer`, `JanetFunction`, `JanetFiber` — GC-managed types

#### Type Checking

- `janet_type(x: Janet) -> JanetType`
- `janet_checktype(x: Janet, t: JanetType) -> bool`
- `janet_truthy(x: Janet) -> bool`

#### Wrapping (Odin → Janet)

- `janet_wrap_nil() -> Janet`
- `janet_wrap_boolean(x: bool) -> Janet`
- `janet_wrap_integer(x: i32) -> Janet`
- `janet_wrap_number(x: f64) -> Janet`
- `janet_wrap_string(s: JanetString) -> Janet`
- `janet_wrap_symbol(s: JanetSymbol) -> Janet`
- `janet_wrap_keyword(k: JanetKeyword) -> Janet`
- `janet_wrap_array(a: ^JanetArray) -> Janet`
- `janet_wrap_table(t: ^JanetTable) -> Janet`
- `janet_wrap_function(f: ^JanetFunction) -> Janet`
- `janet_wrap_cfunction(f: JanetCFunction) -> Janet`

#### Unwrapping (Janet → Odin)

- `janet_unwrap_boolean(x: Janet) -> bool`
- `janet_unwrap_integer(x: Janet) -> i32`
- `janet_unwrap_number(x: Janet) -> f64`
- `janet_unwrap_string(x: Janet) -> JanetString`
- `janet_unwrap_symbol(x: Janet) -> JanetSymbol`
- `janet_unwrap_keyword(x: Janet) -> JanetKeyword`
- `janet_unwrap_array(x: Janet) -> ^JanetArray`
- `janet_unwrap_table(x: Janet) -> ^JanetTable`
- `janet_unwrap_function(x: Janet) -> ^JanetFunction`
- `janet_unwrap_cfunction(x: Janet) -> JanetCFunction`

#### String/Symbol Creation

- `janet_cstring(s: cstring) -> JanetString`
- `janet_csymbol(s: cstring) -> JanetSymbol`
- `janet_ckeyword(s: cstring) -> JanetKeyword`

#### Environment Operations

- `janet_def(env: ^JanetTable, name: cstring, value: Janet, doc: cstring)`
- `janet_table_put(t: ^JanetTable, key: Janet, val: Janet)`
- `janet_table_get(t: ^JanetTable, key: Janet) -> Janet`
- `janet_table_remove(t: ^JanetTable, key: Janet) -> Janet`

#### Evaluation

- `janet_dostring(env: ^JanetTable, str: cstring, source_path: cstring, out: ^Janet) -> i32`
- `janet_dobytes(env: ^JanetTable, bytes: ^u8, len: i32, source_path: cstring, out: ^Janet) -> i32`
- `janet_call(fun: ^JanetFunction, argc: i32, argv: ^Janet) -> Janet`
- `janet_pcall(fun: ^JanetFunction, argc: i32, argv: ^Janet, out: ^Janet, fiber: ^^JanetFiber) -> JanetSignal`

#### Stack Accessors (for C function callbacks)

- `janet_get_integer(argv: ^Janet, n: i32) -> i32`
- `janet_get_number(argv: ^Janet, n: i32) -> f64`
- `janet_get_string(argv: ^Janet, n: i32) -> JanetString`
- `janet_get_boolean(argv: ^Janet, n: i32) -> bool`
- `janet_get_array(argv: ^Janet, n: i32) -> ^JanetArray`
- `janet_get_table(argv: ^Janet, n: i32) -> ^JanetTable`
### janet_engine Package

#### Engine Management

- `JanetEngine` — Engine instance struct
- `EngineConfig` — Configuration struct (boot_script: cstring)
- `janet_engine_init(cfg: EngineConfig) -> (^JanetEngine, bool)`
- `janet_engine_deinit(eng: ^JanetEngine)`

#### Function Registration

- `janet_register(eng: ^JanetEngine, name: cstring, fn: JanetCFunction) -> bool`
- `janet_unregister(eng: ^JanetEngine, name: cstring)`
- `janet_lookup(eng: ^JanetEngine, name: cstring) -> Janet`

#### Code Execution

- `janet_dostring(eng: ^JanetEngine, code: cstring, source: cstring) -> (Janet, bool)`
- `janet_dobytes(eng: ^JanetEngine, bytes: ^u8, len: i32, source: cstring) -> (Janet, bool)`

## Test Results

The test suite includes:

- **High-level API tests** — Validates the janet package (value construction/extraction, function registration, eval, error handling)
- **Janet suite tests** — Validates core Janet functionality (value types, arrays, tables, strings, buffers, tuples, structs, compilation, marshaling, math, OS operations, etc.)
- **Interop tests** — Validates Odin↔Janet data exchange:
  - Basic types (numbers, booleans, strings)
  - Collections (arrays, tables)
  - Function interop (Odin→Janet, Janet→Odin)
  - Complex structures (nested data, mixed types)
  - Error handling
  - Real-world patterns (config loading, data processing)
- **Example integration tests** — Validates gamedev scripting examples:
  - ECS behavior (player movement, enemy AI)
  - Event system (damage, item pickup, dialogue)
  - Quest system (definitions, conditions, rewards)
  - Inventory system (items, stacking, equipment)
  - Dialogue system (branching conversations)
  - AI behavior trees (decision making)
  - Combat system (damage calculation, effects)
  - Save/load system (state persistence)
  - Main game loop (initialization, update cycle)

Run tests:

```bash
odin test tests -out:janet_tests -define:ODIN_TEST_THREADS=1
```

## Examples

The `examples/` directory contains:

- **`main.odin`** — Main example using the high-level API
- **`high_level_example.odin`** — Comprehensive high-level API demonstration
- **Janet scripts** — Gamedev scripting examples:
  - `ecs_behavior.janet` — Entity behavior scripts with player movement and enemy chase AI
  - `event_system.janet` — Event dispatch and handlers for game events
  - `quest_system.janet` — Data-driven quest definitions with conditions and rewards
  - `inventory_system.janet` — Item management with stacking rules and equipment
  - `dialogue_system.janet` — Branching dialogue trees with conditional choices
  - `ai_behavior_tree.janet` — Behavior trees for enemy AI decision making
  - `combat_system.janet` — Damage calculation with armor, crits, and status effects
  - `save_system.janet` — Game state persistence with versioning
  - `main_game.janet` — Main entry point with game lifecycle management

Each example documents the integration boundary:
- **Odin registers** — Functions exposed to Janet
- **Odin calls** — Janet functions invoked by Odin
- Clear separation between Odin's responsibilities (physics, rendering, I/O) and Janet's responsibilities (game logic, rules, data)

## Limitations

- **No subprocess spawning** — Janet's `os/spawn` and related functions require shell execution, which is not available in embedded contexts.
- **No file watching** — Janet C library does not support filewatch on macOS.
- **No event loop integration** — Janet's event system (`ev/*`) requires subprocess spawning and is not exposed.
- **Bundle operations limited** — Janet's bundle system requires file system operations and module loading from disk, which may not work in all embedded scenarios.
- **Single VM per process** — `janet_init()` sets up a global thread-local VM. Multiple engine instances share the same underlying VM.
- **GC management** — The high-level API automatically manages GC rooting, but users working with the low-level API must be careful with long-lived Janet values.

## Project Structure

```
janet-odin/
├── janet/                  # High-level API (recommended)
│   ├── types.odin          # JanetValue, JanetError, JanetResult types
│   ├── conversion.odin     # Value conversion between Odin and Janet
│   ├── eval.odin           # eval(), eval_file(), call() functions
│   ├── registration.odin   # Function registration with Janet
│   └── janet_high.odin     # Package documentation
├── janet_low/              # Low-level FFI bindings
│   ├── types.odin          # Type definitions (Janet, JanetType, etc.)
│   ├── value.odin          # Wrap/unwrap functions
│   ├── stack.odin          # Stack accessors for C callbacks
│   ├── eval.odin           # Evaluation functions (dostring, dobytes, call)
│   ├── collections.odin    # Array, table, buffer operations
│   ├── errors.odin         # Error handling
│   ├── attributes.odin     # Attribute definitions
│   └── janet.odin          # Foreign imports and link declarations
├── janet_engine/           # Engine wrapper
│   ├── engine.odin         # Engine init/deinit, table operations
│   ├── bindings.odin       # Function registration, lookup
│   ├── hotreload.odin      # File hot-reload support
│   └── logger.odin         # Logging utilities
├── examples/               # Example code
│   ├── main.odin           # Main example using high-level API
│   ├── high_level_example.odin  # Comprehensive high-level API demo
│   ├── ecs_behavior.janet
│   ├── event_system.janet
│   ├── quest_system.janet
│   ├── inventory_system.janet
│   ├── dialogue_system.janet
│   ├── ai_behavior_tree.janet
│   ├── combat_system.janet
│   ├── save_system.janet
│   └── main_game.janet
├── vendor/janet/           # Vendored Janet C library (submodule)
├── tests/                  # Test suite
│   ├── smoke_test.odin     # Basic functionality tests
│   ├── integration_test.odin       # Janet suite integration
│   ├── interop_test.odin           # Odin↔Janet interop tests
│   ├── high_level_test.odin        # High-level API tests
│   └── example_integration_test.odin # Example validation tests
└── libjanet.a              # Built Janet static library
```
- **No file watching** — Janet C library does not support filewatch on macOS.
- **No event loop integration** — Janet's event system (`ev/*`) requires subprocess spawning and is not exposed.
- **Bundle operations limited** — Janet's bundle system requires file system operations and module loading from disk, which may not work in all embedded scenarios.
- **Single VM per process** — `janet_init()` sets up a global thread-local VM. Multiple engine instances share the same underlying VM.
- **GC management** — The engine GC-roots the environment table, but users must be careful with long-lived Janet values created outside the engine wrapper.

## Project Structure

```
janet-odin/
├── janet/                  # Low-level FFI bindings
│   ├── types.odin          # Type definitions (Janet, JanetType, etc.)
│   ├── value.odin          # Wrap/unwrap functions
│   ├── stack.odin          # Stack accessors for C callbacks
│   ├── eval.odin           # Evaluation functions (dostring, dobytes, call)
│   ├── collections.odin    # Array, table, buffer operations
│   ├── errors.odin         # Error handling
│   ├── attributes.odin     # Attribute definitions
│   └── janet.odin          # Foreign imports and link declarations
├── janet_engine/           # High-level wrapper
│   ├── engine.odin         # Engine init/deinit, table operations
│   ├── bindings.odin       # Function registration, lookup
│   ├── hotreload.odin      # File hot-reload support
│   └── logger.odin         # Logging utilities
├── examples/               # Gamedev scripting examples
│   ├── ecs_behavior.janet
│   ├── event_system.janet
│   ├── quest_system.janet
│   ├── inventory_system.janet
│   ├── dialogue_system.janet
│   ├── ai_behavior_tree.janet
│   ├── combat_system.janet
│   ├── save_system.janet
│   ── main_game.janet
├── vendor/janet/           # Vendored Janet C library (submodule)
├── tests/                  # Test suite
│   ├── smoke_test.odin     # Basic functionality tests
│   ├── integration_test.odin       # Janet suite integration
│   ├── interop_test.odin           # Odin↔Janet interop tests
│   └── example_integration_test.odin # Example validation tests
└── libjanet.a              # Built Janet static library
```

## License

Apache License 2.0 — see LICENSE file.

## References
- [Janet Documentation](https://janet-lang.org/docs/index.html)
- [Janet C API Documentation](https://janet-lang.org/api/index.html)
- [Odin Programming Language](https://odin-lang.org/)
