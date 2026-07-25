package janet

import janet_low "../janet_low"
import janet_engine "../janet_engine"
import "base:runtime"
import "core:c"
import "core:mem"

// HighLevelFn is the signature for high-level functions that can be registered with Janet.
// Takes a slice of JanetValue arguments and returns a JanetValue result.
HighLevelFn :: proc(args: []JanetValue) -> JanetValue

// Maximum number of high-level functions we can register
MAX_HIGH_LEVEL_FNS :: 64

// Fixed-size array of handlers indexed by wrapper ID
_handler_table: [MAX_HIGH_LEVEL_FNS]HighLevelFn
_next_handler_id: int

// register - Register a high-level function with the Janet engine.
// The function will be callable from Janet code by the given name.
// Returns true on success, false on failure.
register :: proc(eng: ^janet_engine.JanetEngine, name: string, fn: HighLevelFn) -> bool {
	if _next_handler_id >= MAX_HIGH_LEVEL_FNS {
		return false
	}

	// Allocate an ID for this function
	id := _next_handler_id
	_next_handler_id += 1

	// Store the handler in the table
	_handler_table[id] = fn

	// Get the wrapper function for this ID
	wrapper := get_wrapper_for_id(id)

	// Wrap the C function in a Janet value
	wrapper_val := janet_low.janet_wrap_cfunction(wrapper)

	// Register the C function with Janet
	name_cstr := transmute(cstring)mem.raw_data(name)
	janet_low.janet_def(eng.env, name_cstr, wrapper_val, nil)

	return true
}

// unregister - Remove a previously registered function.
// Note: This marks the function as unregistered but doesn't remove it from Janet's environment.
// The function will return an error if called after unregistration.
unregister :: proc(eng: ^janet_engine.JanetEngine, name: string) {
	// We can't easily remove the def from Janet's environment,
	// but we can mark the handler as nil so it returns an error if called.
	// For now, this is a no-op since we'd need to track name->id mapping.
}

// call_handler is the common implementation for all wrappers
call_handler :: proc(handler_id: int, argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {
	// Look up the handler
	if handler_id < 0 || handler_id >= _next_handler_id {
		janet_low.janet_panic("function not found")
		return janet_low.janet_wrap_nil()
	}

	handler := _handler_table[handler_id]
	if handler == nil {
		// Function was unregistered
		janet_low.janet_panic("function not found")
		return janet_low.janet_wrap_nil()
	}

	// Convert arguments to JanetValue
	args := make([]JanetValue, argc)
	// Convert argv pointer to slice for indexing
	argv_slice := mem.slice_ptr(argv, int(argc))
	for i in 0 ..< argc {
		j := argv_slice[i]
		val, err := janet_to_value(j)
		if err != .NONE {
			janet_low.janet_panic("failed to convert argument")
			return janet_low.janet_wrap_nil()
		}
		args[i] = val
	}

	// Call the handler
	result := handler(args)

	// Convert result back to Janet
	janet_result, err := value_to_janet(result)
	if err != .NONE {
		janet_low.janet_panic("failed to convert result")
		return janet_low.janet_wrap_nil()
	}

	return janet_result
}

// Fixed set of wrapper functions
// Each wrapper calls call_handler with its specific ID
wrapper_0 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(0, argc, argv)}
wrapper_1 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(1, argc, argv)}
wrapper_2 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(2, argc, argv)}
wrapper_3 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(3, argc, argv)}
wrapper_4 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(4, argc, argv)}
wrapper_5 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(5, argc, argv)}
wrapper_6 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(6, argc, argv)}
wrapper_7 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(7, argc, argv)}
wrapper_8 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(8, argc, argv)}
wrapper_9 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(9, argc, argv)}
wrapper_10 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(10, argc, argv)}
wrapper_11 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(11, argc, argv)}
wrapper_12 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(12, argc, argv)}
wrapper_13 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(13, argc, argv)}
wrapper_14 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(14, argc, argv)}
wrapper_15 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(15, argc, argv)}
wrapper_16 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(16, argc, argv)}
wrapper_17 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(17, argc, argv)}
wrapper_18 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(18, argc, argv)}
wrapper_19 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(19, argc, argv)}
wrapper_20 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(20, argc, argv)}
wrapper_21 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(21, argc, argv)}
wrapper_22 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(22, argc, argv)}
wrapper_23 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(23, argc, argv)}
wrapper_24 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(24, argc, argv)}
wrapper_25 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(25, argc, argv)}
wrapper_26 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(26, argc, argv)}
wrapper_27 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(27, argc, argv)}
wrapper_28 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(28, argc, argv)}
wrapper_29 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(29, argc, argv)}
wrapper_30 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(30, argc, argv)}
wrapper_31 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(31, argc, argv)}
wrapper_32 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(32, argc, argv)}
wrapper_33 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(33, argc, argv)}
wrapper_34 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(34, argc, argv)}
wrapper_35 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(35, argc, argv)}
wrapper_36 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(36, argc, argv)}
wrapper_37 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(37, argc, argv)}
wrapper_38 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(38, argc, argv)}
wrapper_39 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(39, argc, argv)}
wrapper_40 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(40, argc, argv)}
wrapper_41 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(41, argc, argv)}
wrapper_42 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(42, argc, argv)}
wrapper_43 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(43, argc, argv)}
wrapper_44 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(44, argc, argv)}
wrapper_45 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(45, argc, argv)}
wrapper_46 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(46, argc, argv)}
wrapper_47 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(47, argc, argv)}
wrapper_48 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(48, argc, argv)}
wrapper_49 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(49, argc, argv)}
wrapper_50 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(50, argc, argv)}
wrapper_51 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(51, argc, argv)}
wrapper_52 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(52, argc, argv)}
wrapper_53 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(53, argc, argv)}
wrapper_54 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(54, argc, argv)}
wrapper_55 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(55, argc, argv)}
wrapper_56 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(56, argc, argv)}
wrapper_57 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(57, argc, argv)}
wrapper_58 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(58, argc, argv)}
wrapper_59 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(59, argc, argv)}
wrapper_60 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(60, argc, argv)}
wrapper_61 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(61, argc, argv)}
wrapper_62 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(62, argc, argv)}
wrapper_63 :: proc "c" (argc: i32, argv: ^janet_low.Janet) -> janet_low.Janet {context =
		runtime.default_context()
	return call_handler(63, argc, argv)}

// get_wrapper_for_id returns the wrapper function for a given handler ID
get_wrapper_for_id :: proc(id: int) -> janet_low.JanetCFunction {
	switch id {
	case 0:
		return wrapper_0
	case 1:
		return wrapper_1
	case 2:
		return wrapper_2
	case 3:
		return wrapper_3
	case 4:
		return wrapper_4
	case 5:
		return wrapper_5
	case 6:
		return wrapper_6
	case 7:
		return wrapper_7
	case 8:
		return wrapper_8
	case 9:
		return wrapper_9
	case 10:
		return wrapper_10
	case 11:
		return wrapper_11
	case 12:
		return wrapper_12
	case 13:
		return wrapper_13
	case 14:
		return wrapper_14
	case 15:
		return wrapper_15
	case 16:
		return wrapper_16
	case 17:
		return wrapper_17
	case 18:
		return wrapper_18
	case 19:
		return wrapper_19
	case 20:
		return wrapper_20
	case 21:
		return wrapper_21
	case 22:
		return wrapper_22
	case 23:
		return wrapper_23
	case 24:
		return wrapper_24
	case 25:
		return wrapper_25
	case 26:
		return wrapper_26
	case 27:
		return wrapper_27
	case 28:
		return wrapper_28
	case 29:
		return wrapper_29
	case 30:
		return wrapper_30
	case 31:
		return wrapper_31
	case 32:
		return wrapper_32
	case 33:
		return wrapper_33
	case 34:
		return wrapper_34
	case 35:
		return wrapper_35
	case 36:
		return wrapper_36
	case 37:
		return wrapper_37
	case 38:
		return wrapper_38
	case 39:
		return wrapper_39
	case 40:
		return wrapper_40
	case 41:
		return wrapper_41
	case 42:
		return wrapper_42
	case 43:
		return wrapper_43
	case 44:
		return wrapper_44
	case 45:
		return wrapper_45
	case 46:
		return wrapper_46
	case 47:
		return wrapper_47
	case 48:
		return wrapper_48
	case 49:
		return wrapper_49
	case 50:
		return wrapper_50
	case 51:
		return wrapper_51
	case 52:
		return wrapper_52
	case 53:
		return wrapper_53
	case 54:
		return wrapper_54
	case 55:
		return wrapper_55
	case 56:
		return wrapper_56
	case 57:
		return wrapper_57
	case 58:
		return wrapper_58
	case 59:
		return wrapper_59
	case 60:
		return wrapper_60
	case 61:
		return wrapper_61
	case 62:
		return wrapper_62
	case 63:
		return wrapper_63
	}
	return nil
}
