// Package janet provides a high-level API for embedding the Janet scripting language.
//
// This package wraps Janet's low-level C API with Odin-native types and automatic
// resource management. Users can register functions, evaluate code, and exchange values
// without ever touching janet_low.Janet or janet_low.JanetType.
//
// # When to use janet vs janet_low
//
// Use janet for most embedding tasks:
//   - Registering Odin functions callable from Janet
//   - Evaluating Janet code strings or files
//   - Calling Janet functions from Odin
//   - Exchanging values between Odin and Janet
//
// Use the low-level janet_low package when you need:
//   - Direct control over Janet's type system (symbols, keywords, buffers)
//   - Manual GC management
//   - Advanced features like fibers, parsers, or abstract types
//
// # Type mapping
//
// JanetValue uses Odin-native types:
//   - nil         -> JanetValue.nil
//   - boolean     -> JanetValue.bool
//   - number (int)-> JanetValue.i64
//   - number (flt)-> JanetValue.f64
//   - string      -> JanetValue.string (Odin string, bytes copied)
//   - array/tuple -> JanetValue.[]JanetValue (recursively converted)
//   - table/struct-> JanetValue.map[string]JanetValue (keys must be string-like)
//
// # GC management
//
// The high-level API automatically roots values during conversion to prevent premature
// collection. For long-lived values (arrays, tables, strings), the API calls janet_low.janet_gcroot()
// internally. You generally don't need to manage GC manually.
//
// # Example usage
//
//   import "janet"
//   import janet_engine
//
//   // Create an engine
//   eng, ok := janet_engine.janet_engine_init(janet_engine.EngineConfig{})
//   defer janet_engine.janet_engine_deinit(eng)
//
//   // Register a function
//   janet.register(eng, "add", proc(args: []janet.JanetValue) -> janet.JanetValue {
//       a, _ := janet.to_integer(args[0])
//       b, _ := janet.to_integer(args[1])
//       return janet.janet_integer(a + b)
//   })
//
//   // Evaluate code
//   result, err := janet.eval(eng, "(add 1 2)")
//   if err == .NONE {
//       if n, ok := janet.to_integer(result); ok {
//           fmt.println("Result: ", n) // Prints: Result: 3
//       }
//   }
package janet

// Re-export all public symbols from sub-files for convenient access
