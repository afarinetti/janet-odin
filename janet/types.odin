package janet

// Nil - Represents a nil value in JanetValue union
Nil :: struct {
}

// JanetValue - High-level tagged union representing Janet values using Odin-native types.
// This union hides Janet's internal type system (JanetType enum, distinct string/symbol/keyword
// types, GC-managed collections) behind familiar Odin types.
//
// Type mapping:
//   Janet nil          -> JanetValue (Nil{})
//   Janet boolean      -> JanetValue (bool)
//   Janet number (int) -> JanetValue (i64)
//   Janet number (flt) -> JanetValue (f64)
//   Janet string       -> JanetValue (string)
//   Janet array/tuple  -> JanetValue ([]JanetValue)
//   Janet table/struct -> JanetValue (map[string]JanetValue)
JanetValue :: union {
	Nil,
	bool,
	i64,
	f64,
	string,
	[]JanetValue,
	map[string]JanetValue,
}

// JanetError - Error codes returned by high-level API operations.
JanetError :: enum {
	NONE,
	COMPILE_ERROR,
	RUNTIME_ERROR,
	TYPE_ERROR,
	FILE_NOT_FOUND,
}

// JanetResult - Result of a high-level API operation (eval, call, etc).
// Contains the returned value, an error code, and a human-readable error message.
JanetResult :: struct {
	value:   JanetValue,
	error:   JanetError,
	message: string,
}
