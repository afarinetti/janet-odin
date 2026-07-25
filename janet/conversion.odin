package janet

import janet_low "../janet_low"
import "core:c"
import "core:mem"

// value_to_janet - Convert a high-level JanetValue to a low-level janet_low.Janet value.
// Pattern matches on JanetValue and calls appropriate janet_wrap_* functions.
// For strings, creates JanetString via janet_cstring.
// For arrays/tables, recursively converts elements.
//
// GC management: This function roots long-lived values (arrays, tables, strings) to prevent
// premature collection. The caller is responsible for calling janet_gcunroot when done.
value_to_janet :: proc(v: JanetValue) -> (janet_low.Janet, JanetError) {
	if _, ok := v.(Nil); ok {
		return janet_low.janet_wrap_nil(), .NONE
	}
	if b, ok := v.(bool); ok {
		return janet_low.janet_wrap_boolean(b), .NONE
	}
	if n, ok := v.(i64); ok {
		return janet_low.janet_wrap_integer64(n), .NONE
	}
	if n, ok := v.(f64); ok {
		return janet_low.janet_wrap_number(n), .NONE
	}
	if s, ok := v.(string); ok {
		js := _odin_string_to_janet(s)
		result := janet_low.janet_wrap_string(js)
		janet_low.janet_gcroot(result)
		return result, .NONE
	}
	if arr, ok := v.([]JanetValue); ok {
		janet_arr := _odin_array_to_janet(arr)
		result := janet_low.janet_wrap_array(janet_arr)
		janet_low.janet_gcroot(result)
		return result, .NONE
	}
	if tbl, ok := v.(map[string]JanetValue); ok {
		janet_tbl := _odin_table_to_janet(tbl)
		result := janet_low.janet_wrap_table(janet_tbl)
		janet_low.janet_gcroot(result)
		return result, .NONE
	}
	return janet_low.janet_wrap_nil(), .TYPE_ERROR
}

// Helper: Convert Odin string to JanetString
_odin_string_to_janet :: proc(s: string) -> janet_low.JanetString {
	if len(s) == 0 {
		return janet_low.janet_cstring("")
	}
	cstr := transmute(cstring)mem.raw_data(s)
	return janet_low.janet_cstring(cstr)
}

// Helper: Convert []JanetValue to ^JanetArray
_odin_array_to_janet :: proc(items: []JanetValue) -> ^janet_low.JanetArray {
	arr := janet_low.janet_array(i32(len(items)))
	for item in items {
		j, _ := value_to_janet(item)
		janet_low.janet_array_push(arr, j)
	}
	return arr
}

// Helper: Convert map[string]JanetValue to ^JanetTable
_odin_table_to_janet :: proc(pairs: map[string]JanetValue) -> ^janet_low.JanetTable {
	tbl := janet_low.janet_table(i32(len(pairs)))
	for k, v in pairs {
		key := _odin_string_to_janet(k)
		key_j := janet_low.janet_wrap_string(key)
		val_j, _ := value_to_janet(v)
		janet_low.janet_table_put(tbl, key_j, val_j)
	}
	return tbl
}

// janet_to_value - Convert a low-level janet_low.Janet value to a high-level JanetValue.
// Inspects the Janet type and recursively converts to Odin-native types.
// Returns (value, error) where error is NONE on success.
janet_to_value :: proc(j: janet_low.Janet) -> (JanetValue, JanetError) {
	t := janet_low.janet_type(j)

	#partial switch t {
	case .NIL:
		return Nil{}, .NONE

	case .BOOLEAN:
		b := janet_low.janet_unwrap_boolean(j)
		return b, .NONE

	case .NUMBER:
		n := janet_low.janet_unwrap_number(j)
		if n == f64(i64(n)) {
			return i64(n), .NONE
		} else {
			return n, .NONE
		}

	case .STRING:
		s := janet_low.janet_unwrap_string(j)
		str := _janet_string_to_odin(s)
		return str, .NONE

	case .SYMBOL:
		s := janet_low.janet_unwrap_symbol(j)
		str := _janet_string_to_odin(transmute(janet_low.JanetString)s)
		return str, .NONE

	case .KEYWORD:
		k := janet_low.janet_unwrap_keyword(j)
		str := _janet_string_to_odin(transmute(janet_low.JanetString)k)
		if len(str) > 0 && str[0] == ':' {
			str = str[1:]
		}
		return str, .NONE

	case .ARRAY:
		arr := janet_low.janet_unwrap_array(j)
		return _janet_array_to_value(arr), .NONE

	case .TUPLE:
		tup := janet_low.janet_unwrap_tuple(j)
		return _janet_tuple_to_value(tup), .NONE

	case .TABLE:
		tbl := janet_low.janet_unwrap_table(j)
		return _janet_table_to_value(tbl), .NONE

	case .STRUCT:
		st := janet_low.janet_unwrap_struct(j)
		return _janet_struct_to_value(st), .NONE
	}

	return Nil{}, .TYPE_ERROR
}

// Helper: Convert JanetString (^u8) to Odin string
_janet_string_to_odin :: proc(s: janet_low.JanetString) -> string {
	if s == nil {
		return ""
	}
	str_len := janet_low.janet_string_length(s)
	if str_len == 0 {
		return ""
	}
	// Convert pointer to slice and copy
	s_slice := mem.slice_ptr(cast(^u8)s, int(str_len))
	return string(s_slice)
}

_janet_array_to_value :: proc(arr: ^janet_low.JanetArray) -> JanetValue {
	arr_len := janet_low.janet_array_length(arr)
	result := make([]JanetValue, arr_len)
	for i in 0 ..< arr_len {
		elem := janet_low.janet_array_get(arr, i32(i))
		val, _ := janet_to_value(elem)
		result[i] = val
	}
	return result
}

// Helper: Convert JanetTuple to []JanetValue
_janet_tuple_to_value :: proc(tup: janet_low.JanetTuple) -> JanetValue {
	tup_len := janet_low.janet_tuple_length(tup)
	result := make([]JanetValue, tup_len)
	// Convert tuple pointer to slice for indexing
	tup_slice := mem.slice_ptr(tup, int(tup_len))
	for i in 0 ..< tup_len {
		elem := tup_slice[i]
		val, _ := janet_to_value(elem)
		result[i] = val
	}
	return result
}

// Helper: Convert JanetTable to map[string]JanetValue
_janet_table_to_value :: proc(tbl: ^janet_low.JanetTable) -> JanetValue {
	result := make(map[string]JanetValue)
	key := janet_low.janet_wrap_nil()
	for {
		out: janet_low.Janet
		status := janet_low.janet_next(janet_low.janet_wrap_table(tbl), key, &out)
		if status != 0 {
			break
		}
		key_str, key_ok := _janet_key_to_string(out)
		if !key_ok {
			key = out
			continue
		}
		val_j := janet_low.janet_table_get(tbl, out)
		val, _ := janet_to_value(val_j)
		result[key_str] = val
		key = out
	}
	return result
}

// Helper: Convert JanetStruct to map[string]JanetValue
_janet_struct_to_value :: proc(st: janet_low.JanetStruct) -> JanetValue {
	result := make(map[string]JanetValue)
	head := janet_low.janet_struct_head(st)
	struct_len := head^.length
	// Convert struct pointer to slice for indexing
	st_slice := mem.slice_ptr(st, int(struct_len))
	for i in 0 ..< struct_len {
		kv := &st_slice[i]
		key := kv^.key
		val_j := kv^.value

		key_str, key_ok := _janet_key_to_string(key)
		if !key_ok {
			continue
		}
		val, _ := janet_to_value(val_j)
		result[key_str] = val
	}
	return result
}

// Helper: Convert a Janet key to string (for table/struct keys)
_janet_key_to_string :: proc(k: janet_low.Janet) -> (string, bool) {
	t := janet_low.janet_type(k)
	#partial switch t {
	case .STRING:
		s := janet_low.janet_unwrap_string(k)
		return _janet_string_to_odin(s), true
	case .SYMBOL:
		s := janet_low.janet_unwrap_symbol(k)
		return _janet_string_to_odin(janet_low.JanetString(s)), true
	case .KEYWORD:
		kw := janet_low.janet_unwrap_keyword(k)
		str := _janet_string_to_odin(janet_low.JanetString(kw))
		if len(str) > 0 && str[0] == ':' {
			str = str[1:]
		}
		return str, true
	}
	return "", false
}
