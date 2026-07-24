package janet

import "core:c"

foreign import janet_lib {"../libjanet.a", "system:c"}

foreign janet_lib {
	// ===== VM lifecycle =====
	@(link_name = "janet_init")
	janet_init :: proc() -> i32 ---

	@(link_name = "janet_deinit")
	janet_deinit :: proc() ---

	@(link_name = "janet_vm_alloc")
	janet_vm_alloc :: proc() -> ^JanetVM ---

	@(link_name = "janet_vm_free")
	janet_vm_free :: proc(vm: ^JanetVM) ---

	@(link_name = "janet_local_vm")
	janet_local_vm :: proc() -> ^JanetVM ---

	@(link_name = "janet_vm_load")
	janet_vm_load :: proc(from: ^JanetVM) ---

	@(link_name = "janet_vm_save")
	janet_vm_save :: proc(into: ^JanetVM) ---

	@(link_name = "janet_core_env")
	janet_core_env :: proc(replacements: ^JanetTable) -> ^JanetTable ---

	@(link_name = "janet_core_lookup_table")
	janet_core_lookup_table :: proc(replacements: ^JanetTable) -> ^JanetTable ---

	// ===== GC =====
	@(link_name = "janet_gcroot")
	_janet_gcroot :: proc(root: Janet) ---

	@(link_name = "janet_gcunroot")
	_janet_gcunroot :: proc(root: Janet) -> c.int ---

	@(link_name = "janet_gcunrootall")
	_janet_gcunrootall :: proc(root: Janet) -> c.int ---

	@(link_name = "janet_gclock")
	_janet_gclock :: proc() -> c.int ---

	@(link_name = "janet_gcunlock")
	_janet_gcunlock :: proc(handle: c.int) ---

	@(link_name = "janet_gcpressure")
	_janet_gcpressure :: proc(s: c.size_t) ---

	@(link_name = "janet_collect")
	_janet_collect :: proc() ---

	@(link_name = "janet_gcalloc")
	_janet_gcalloc :: proc(size: c.size_t, flags: u32) -> rawptr ---

	// ===== Type checking =====
	@(link_name = "janet_type")
	_janet_type :: proc(x: Janet) -> JanetType ---

	@(link_name = "janet_checktype")
	_janet_checktype :: proc(x: Janet, t: JanetType) -> c.int ---

	@(link_name = "janet_checktypes")
	_janet_checktypes :: proc(x: Janet, typeflags: c.int) -> c.int ---

	@(link_name = "janet_truthy")
	_janet_truthy :: proc(x: Janet) -> c.int ---

	// ===== Wrap functions =====
	@(link_name = "janet_wrap_nil")
	_janet_wrap_nil :: proc() -> Janet ---

	@(link_name = "janet_wrap_true")
	_janet_wrap_true :: proc() -> Janet ---

	@(link_name = "janet_wrap_false")
	_janet_wrap_false :: proc() -> Janet ---

	@(link_name = "janet_wrap_boolean")
	_janet_wrap_boolean :: proc(x: c.int) -> Janet ---

	@(link_name = "janet_wrap_number")
	_janet_wrap_number :: proc(x: f64) -> Janet ---


	@(link_name = "janet_wrap_string")
	_janet_wrap_string :: proc(x: JanetString) -> Janet ---

	@(link_name = "janet_wrap_symbol")
	_janet_wrap_symbol :: proc(x: JanetSymbol) -> Janet ---

	@(link_name = "janet_wrap_keyword")
	_janet_wrap_keyword :: proc(x: JanetKeyword) -> Janet ---

	@(link_name = "janet_wrap_array")
	_janet_wrap_array :: proc(x: ^JanetArray) -> Janet ---

	@(link_name = "janet_wrap_tuple")
	_janet_wrap_tuple :: proc(x: JanetTuple) -> Janet ---

	@(link_name = "janet_wrap_struct")
	_janet_wrap_struct :: proc(x: JanetStruct) -> Janet ---

	@(link_name = "janet_wrap_fiber")
	_janet_wrap_fiber :: proc(x: ^JanetFiber) -> Janet ---

	@(link_name = "janet_wrap_buffer")
	_janet_wrap_buffer :: proc(x: ^JanetBuffer) -> Janet ---

	@(link_name = "janet_wrap_function")
	_janet_wrap_function :: proc(x: ^JanetFunction) -> Janet ---

	@(link_name = "janet_wrap_cfunction")
	_janet_wrap_cfunction :: proc(x: JanetCFunction) -> Janet ---

	@(link_name = "janet_wrap_table")
	_janet_wrap_table :: proc(x: ^JanetTable) -> Janet ---

	@(link_name = "janet_wrap_abstract")
	_janet_wrap_abstract :: proc(x: JanetAbstract) -> Janet ---

	@(link_name = "janet_wrap_pointer")
	_janet_wrap_pointer :: proc(x: rawptr) -> Janet ---

	// ===== Unwrap functions =====
	@(link_name = "janet_unwrap_boolean")
	_janet_unwrap_boolean :: proc(x: Janet) -> c.int ---

	@(link_name = "janet_unwrap_number")
	_janet_unwrap_number :: proc(x: Janet) -> f64 ---

	@(link_name = "janet_unwrap_integer")
	_janet_unwrap_integer :: proc(x: Janet) -> i32 ---

	@(link_name = "janet_unwrap_string")
	_janet_unwrap_string :: proc(x: Janet) -> JanetString ---

	@(link_name = "janet_unwrap_symbol")
	_janet_unwrap_symbol :: proc(x: Janet) -> JanetSymbol ---

	@(link_name = "janet_unwrap_keyword")
	_janet_unwrap_keyword :: proc(x: Janet) -> JanetKeyword ---

	@(link_name = "janet_unwrap_array")
	_janet_unwrap_array :: proc(x: Janet) -> ^JanetArray ---

	@(link_name = "janet_unwrap_tuple")
	_janet_unwrap_tuple :: proc(x: Janet) -> JanetTuple ---

	@(link_name = "janet_unwrap_struct")
	_janet_unwrap_struct :: proc(x: Janet) -> JanetStruct ---

	@(link_name = "janet_unwrap_fiber")
	_janet_unwrap_fiber :: proc(x: Janet) -> ^JanetFiber ---

	@(link_name = "janet_unwrap_buffer")
	_janet_unwrap_buffer :: proc(x: Janet) -> ^JanetBuffer ---

	@(link_name = "janet_unwrap_function")
	_janet_unwrap_function :: proc(x: Janet) -> ^JanetFunction ---

	@(link_name = "janet_unwrap_cfunction")
	_janet_unwrap_cfunction :: proc(x: Janet) -> JanetCFunction ---

	@(link_name = "janet_unwrap_table")
	_janet_unwrap_table :: proc(x: Janet) -> ^JanetTable ---

	@(link_name = "janet_unwrap_abstract")
	_janet_unwrap_abstract :: proc(x: Janet) -> JanetAbstract ---

	@(link_name = "janet_unwrap_pointer")
	_janet_unwrap_pointer :: proc(x: Janet) -> rawptr ---

	// ===== Stack accessors =====
	@(link_name = "janet_getboolean")
	_janet_getboolean :: proc(argv: ^Janet, n: i32) -> c.int ---

	@(link_name = "janet_getinteger")
	_janet_getinteger :: proc(argv: ^Janet, n: i32) -> i32 ---

	@(link_name = "janet_getinteger64")
	_janet_getinteger64 :: proc(argv: ^Janet, n: i32) -> i64 ---

	@(link_name = "janet_getnumber")
	_janet_getnumber :: proc(argv: ^Janet, n: i32) -> f64 ---

	@(link_name = "janet_getstring")
	_janet_getstring :: proc(argv: ^Janet, n: i32) -> JanetString ---

	@(link_name = "janet_getcstring")
	_janet_getcstring :: proc(argv: ^Janet, n: i32) -> cstring ---

	@(link_name = "janet_getsymbol")
	_janet_getsymbol :: proc(argv: ^Janet, n: i32) -> JanetSymbol ---

	@(link_name = "janet_getkeyword")
	_janet_getkeyword :: proc(argv: ^Janet, n: i32) -> JanetKeyword ---

	@(link_name = "janet_getarray")
	_janet_getarray :: proc(argv: ^Janet, n: i32) -> ^JanetArray ---

	@(link_name = "janet_gettuple")
	_janet_gettuple :: proc(argv: ^Janet, n: i32) -> JanetTuple ---

	@(link_name = "janet_gettable")
	_janet_gettable :: proc(argv: ^Janet, n: i32) -> ^JanetTable ---

	@(link_name = "janet_getstruct")
	_janet_getstruct :: proc(argv: ^Janet, n: i32) -> JanetStruct ---

	@(link_name = "janet_getbuffer")
	_janet_getbuffer :: proc(argv: ^Janet, n: i32) -> ^JanetBuffer ---

	@(link_name = "janet_getfiber")
	_janet_getfiber :: proc(argv: ^Janet, n: i32) -> ^JanetFiber ---

	@(link_name = "janet_getfunction")
	_janet_getfunction :: proc(argv: ^Janet, n: i32) -> ^JanetFunction ---

	@(link_name = "janet_getcfunction")
	_janet_getcfunction :: proc(argv: ^Janet, n: i32) -> JanetCFunction ---

	@(link_name = "janet_getpointer")
	_janet_getpointer :: proc(argv: ^Janet, n: i32) -> rawptr ---

	@(link_name = "janet_getabstract")
	_janet_getabstract :: proc(argv: ^Janet, n: i32) -> JanetAbstract ---

	@(link_name = "janet_getsize")
	_janet_getsize :: proc(argv: ^Janet, n: i32) -> c.size_t ---

	@(link_name = "janet_getnat")
	_janet_getnat :: proc(argv: ^Janet, n: i32) -> i32 ---

	// ===== Stack manipulation =====
	@(link_name = "janet_fiber_push")
	_janet_fiber_push :: proc(fiber: ^JanetFiber, x: Janet) ---

	@(link_name = "janet_fiber_push2")
	_janet_fiber_push2 :: proc(fiber: ^JanetFiber, x: Janet, y: Janet) ---

	@(link_name = "janet_fiber_push3")
	_janet_fiber_push3 :: proc(fiber: ^JanetFiber, x: Janet, y: Janet, z: Janet) ---

	@(link_name = "janet_fiber_pushn")
	_janet_fiber_pushn :: proc(fiber: ^JanetFiber, arr: ^JanetArray, offset: i32, n: i32) ---

	// ===== Compilation and evaluation =====
	@(link_name = "janet_compile")
	_janet_compile :: proc(source: Janet, env: ^JanetTable, where_name: JanetString) -> JanetCompileResult ---

	@(link_name = "janet_compile_lint")
	_janet_compile_lint :: proc(source: Janet, env: ^JanetTable, where_name: JanetString, lint: ^JanetArray) -> JanetCompileResult ---

	@(link_name = "janet_dostring")
	_janet_dostring :: proc(env: ^JanetTable, str: cstring, sourcePath: cstring, out: ^Janet) -> i32 ---

	@(link_name = "janet_dobytes")
	_janet_dobytes :: proc(env: ^JanetTable, bytes: ^u8, len: i32, sourcePath: cstring, out: ^Janet) -> i32 ---

	@(link_name = "janet_call")
	_janet_call :: proc(fun: ^JanetFunction, argc: i32, argv: ^Janet) -> Janet ---

	@(link_name = "janet_pcall")
	_janet_pcall :: proc(fun: ^JanetFunction, argc: i32, argv: ^Janet, out: ^Janet, fiber: ^^JanetFiber) -> JanetSignal ---

	@(link_name = "janet_continue")
	_janet_continue :: proc(fiber: ^JanetFiber, in_val: Janet, out: ^Janet) -> JanetSignal ---

	@(link_name = "janet_continue_signal")
	_janet_continue_signal :: proc(fiber: ^JanetFiber, in_val: Janet, out: ^Janet, signal: JanetSignal) -> JanetSignal ---

	// ===== Fiber operations =====
	@(link_name = "janet_fiber")
	_janet_fiber :: proc(callee: ^JanetFunction, capacity: i32, argc: i32, argv: ^Janet) -> ^JanetFiber ---

	@(link_name = "janet_fiber_reset")
	_janet_fiber_reset :: proc(fiber: ^JanetFiber, callee: ^JanetFunction, argc: i32, argv: ^Janet) ---

	@(link_name = "janet_fiber_status")
	_janet_fiber_status :: proc(fiber: ^JanetFiber) -> JanetFiberStatus ---

	@(link_name = "janet_fiber_can_resume")
	_janet_fiber_can_resume :: proc(fiber: ^JanetFiber) -> i32 ---

	@(link_name = "janet_fiber_setcapacity")
	_janet_fiber_setcapacity :: proc(fiber: ^JanetFiber, capacity: i32) ---

	@(link_name = "janet_stacktrace")
	_janet_stacktrace :: proc(fiber: ^JanetFiber, err: Janet) ---

	@(link_name = "janet_root_fiber")
	_janet_root_fiber :: proc() -> ^JanetFiber ---

	@(link_name = "janet_current_fiber")
	_janet_current_fiber :: proc() -> ^JanetFiber ---

	// ===== Event loop =====
	@(link_name = "janet_loop")
	_janet_loop :: proc() ---

	@(link_name = "janet_loop_done")
	_janet_loop_done :: proc() -> i32 ---

	@(link_name = "janet_loop1")
	_janet_loop1 :: proc() -> ^JanetFiber ---

	@(link_name = "janet_loop1_interrupt")
	_janet_loop1_interrupt :: proc(vm: ^JanetVM) ---

	@(link_name = "janet_loop_fiber")
	_janet_loop_fiber :: proc(fiber: ^JanetFiber) -> i32 ---

	@(link_name = "janet_schedule")
	_janet_schedule :: proc(fiber: ^JanetFiber, value: Janet) ---

	@(link_name = "janet_schedule_signal")
	_janet_schedule_signal :: proc(fiber: ^JanetFiber, value: Janet, sig: JanetSignal) ---

	@(link_name = "janet_cancel")
	_janet_cancel :: proc(fiber: ^JanetFiber, value: Janet) ---

	// ===== String operations =====
	@(link_name = "janet_cstring")
	_janet_cstring :: proc(cstr: cstring) -> JanetString ---


	@(link_name = "janet_string")
	_janet_string :: proc(buf: ^u8, len: i32) -> JanetString ---

	@(link_name = "janet_string_begin")
	_janet_string_begin :: proc(length: i32) -> ^u8 ---

	@(link_name = "janet_string_end")
	_janet_string_end :: proc(str: ^u8) -> JanetString ---

	@(link_name = "janet_string_compare")
	_janet_string_compare :: proc(lhs: JanetString, rhs: JanetString) -> i32 ---

	@(link_name = "janet_string_equal")
	_janet_string_equal :: proc(lhs: JanetString, rhs: JanetString) -> i32 ---

	@(link_name = "janet_description")
	_janet_description :: proc(x: Janet) -> JanetString ---

	@(link_name = "janet_to_string")
	_janet_to_string :: proc(x: Janet) -> JanetString ---

	@(link_name = "janet_symbol")
	_janet_symbol :: proc(str: ^u8, len: i32) -> JanetSymbol ---

	@(link_name = "janet_csymbol")
	_janet_csymbol :: proc(str: cstring) -> JanetSymbol ---

	@(link_name = "janet_symbol_gen")
	_janet_symbol_gen :: proc() -> JanetSymbol ---

	// ===== Table operations =====
	@(link_name = "janet_table")
	_janet_table :: proc(capacity: i32) -> ^JanetTable ---

	@(link_name = "janet_table_init")
	_janet_table_init :: proc(table: ^JanetTable, capacity: i32) -> ^JanetTable ---

	@(link_name = "janet_table_deinit")
	_janet_table_deinit :: proc(table: ^JanetTable) ---

	@(link_name = "janet_table_get")
	_janet_table_get :: proc(t: ^JanetTable, key: Janet) -> Janet ---

	@(link_name = "janet_table_get_ex")
	_janet_table_get_ex :: proc(t: ^JanetTable, key: Janet, which: ^^JanetTable) -> Janet ---

	@(link_name = "janet_table_rawget")
	_janet_table_rawget :: proc(t: ^JanetTable, key: Janet) -> Janet ---

	@(link_name = "janet_table_put")
	_janet_table_put :: proc(t: ^JanetTable, key: Janet, val: Janet) ---

	@(link_name = "janet_table_remove")
	_janet_table_remove :: proc(t: ^JanetTable, key: Janet) -> Janet ---

	@(link_name = "janet_table_clear")
	_janet_table_clear :: proc(t: ^JanetTable) ---

	@(link_name = "janet_table_clone")
	_janet_table_clone :: proc(table: ^JanetTable) -> ^JanetTable ---

	@(link_name = "janet_table_to_struct")
	_janet_table_to_struct :: proc(t: ^JanetTable) -> JanetStruct ---

	@(link_name = "janet_tablen")
	_janet_tablen :: proc(t: ^JanetTable) -> i32 ---

	// ===== Array operations =====
	@(link_name = "janet_array")
	_janet_array :: proc(capacity: i32) -> ^JanetArray ---

	@(link_name = "janet_array_n")
	_janet_array_n :: proc(elements: ^Janet, n: i32) -> ^JanetArray ---

	@(link_name = "janet_array_ensure")
	_janet_array_ensure :: proc(array: ^JanetArray, capacity: i32, growth: i32) ---

	@(link_name = "janet_array_setcount")
	_janet_array_setcount :: proc(array: ^JanetArray, count: i32) ---

	@(link_name = "janet_array_push")
	_janet_array_push :: proc(array: ^JanetArray, x: Janet) ---

	@(link_name = "janet_array_pop")
	_janet_array_pop :: proc(array: ^JanetArray) -> Janet ---

	@(link_name = "janet_array_peek")
	_janet_array_peek :: proc(array: ^JanetArray) -> Janet ---

	// ===== Buffer operations =====
	@(link_name = "janet_buffer")
	_janet_buffer :: proc(capacity: i32) -> ^JanetBuffer ---

	@(link_name = "janet_buffer_init")
	_janet_buffer_init :: proc(buffer: ^JanetBuffer, capacity: i32) -> ^JanetBuffer ---

	@(link_name = "janet_buffer_deinit")
	_janet_buffer_deinit :: proc(buffer: ^JanetBuffer) ---

	@(link_name = "janet_buffer_ensure")
	_janet_buffer_ensure :: proc(buffer: ^JanetBuffer, capacity: i32, growth: i32) ---

	@(link_name = "janet_buffer_setcount")
	_janet_buffer_setcount :: proc(buffer: ^JanetBuffer, count: i32) ---

	@(link_name = "janet_buffer_push_bytes")
	_janet_buffer_push_bytes :: proc(b: ^JanetBuffer, data: ^u8, len: i32) ---

	@(link_name = "janet_buffer_push_string")
	_janet_buffer_push_string :: proc(b: ^JanetBuffer, s: JanetString) ---

	@(link_name = "janet_buffer_push_cstring")
	_janet_buffer_push_cstring :: proc(b: ^JanetBuffer, s: cstring) ---

	@(link_name = "janet_buffer_push_u8")
	_janet_buffer_push_u8 :: proc(b: ^JanetBuffer, x: u8) ---

	@(link_name = "janet_buffer_push_u16")
	_janet_buffer_push_u16 :: proc(b: ^JanetBuffer, x: u16) ---

	@(link_name = "janet_buffer_push_u32")
	_janet_buffer_push_u32 :: proc(b: ^JanetBuffer, x: u32) ---

	@(link_name = "janet_buffer_push_u64")
	_janet_buffer_push_u64 :: proc(b: ^JanetBuffer, x: u64) ---

	// ===== Struct operations =====
	@(link_name = "janet_struct_begin")
	_janet_struct_begin :: proc(count: i32) -> ^JanetKV ---

	@(link_name = "janet_struct_put")
	_janet_struct_put :: proc(st: ^JanetKV, key: Janet, value: Janet) ---

	@(link_name = "janet_struct_end")
	_janet_struct_end :: proc(st: ^JanetKV) -> JanetStruct ---

	@(link_name = "janet_struct_get")
	_janet_struct_get :: proc(st: JanetStruct, key: Janet) -> Janet ---

	@(link_name = "janet_struct_rawget")
	_janet_struct_rawget :: proc(st: JanetStruct, key: Janet) -> Janet ---

	@(link_name = "janet_struct_to_table")
	_janet_struct_to_table :: proc(st: JanetStruct) -> ^JanetTable ---

	// ===== Tuple operations =====
	@(link_name = "janet_tuple_begin")
	_janet_tuple_begin :: proc(length: i32) -> ^Janet ---

	@(link_name = "janet_tuple_end")
	_janet_tuple_end :: proc(tuple: ^Janet) -> JanetTuple ---

	@(link_name = "janet_tuple_n")
	_janet_tuple_n :: proc(values: ^Janet, n: i32) -> JanetTuple ---

	// ===== Abstract types =====
	@(link_name = "janet_abstract")
	_janet_abstract :: proc(at: ^JanetAbstractType, size: c.size_t) -> JanetAbstract ---

	@(link_name = "janet_abstract_begin")
	_janet_abstract_begin :: proc(at: ^JanetAbstractType, size: c.size_t) -> rawptr ---

	@(link_name = "janet_abstract_end")
	_janet_abstract_end :: proc(x: rawptr) -> JanetAbstract ---

	@(link_name = "janet_abstract_incref")
	_janet_abstract_incref :: proc(abst: rawptr) -> i32 ---

	@(link_name = "janet_abstract_decref")
	_janet_abstract_decref :: proc(abst: rawptr) -> i32 ---

	// ===== Resolve / def / var =====
	@(link_name = "janet_resolve")
	_janet_resolve :: proc(env: ^JanetTable, sym: JanetSymbol, out: ^Janet) -> JanetBindingType ---

	@(link_name = "janet_resolve_ext")
	_janet_resolve_ext :: proc(env: ^JanetTable, sym: JanetSymbol) -> JanetBinding ---

	@(link_name = "janet_def")
	_janet_def :: proc(env: ^JanetTable, name: cstring, value: Janet, doc: cstring) ---

	@(link_name = "janet_var")
	_janet_var :: proc(env: ^JanetTable, name: cstring, value: Janet, doc: cstring) ---

	@(link_name = "janet_cfuns")
	_janet_cfuns :: proc(env: ^JanetTable, regprefix: cstring, cfuns: ^JanetReg) ---

	// ===== Parser =====
	@(link_name = "janet_parser_init")
	_janet_parser_init :: proc(parser: ^JanetParser) ---

	@(link_name = "janet_parser_deinit")
	_janet_parser_deinit :: proc(parser: ^JanetParser) ---

	@(link_name = "janet_parser_consume")
	_janet_parser_consume :: proc(parser: ^JanetParser, c: u8) ---

	@(link_name = "janet_parser_eof")
	_janet_parser_eof :: proc(parser: ^JanetParser) ---

	@(link_name = "janet_parser_status")
	_janet_parser_status :: proc(parser: ^JanetParser) -> i32 ---

	@(link_name = "janet_parser_has_more")
	_janet_parser_has_more :: proc(parser: ^JanetParser) -> i32 ---

	@(link_name = "janet_parser_produce")
	_janet_parser_produce :: proc(parser: ^JanetParser) -> Janet ---

	@(link_name = "janet_parser_error")
	_janet_parser_error :: proc(parser: ^JanetParser) -> cstring ---

	@(link_name = "janet_parser_flush")
	_janet_parser_flush :: proc(parser: ^JanetParser) ---

	// ===== Number scanning =====
	@(link_name = "janet_scan_number")
	_janet_scan_number :: proc(str: ^u8, len: i32, out: ^f64) -> i32 ---

	@(link_name = "janet_scan_int64")
	_janet_scan_int64 :: proc(str: ^u8, len: i32, out: ^i64) -> i32 ---

	@(link_name = "janet_scan_uint64")
	_janet_scan_uint64 :: proc(str: ^u8, len: i32, out: ^u64) -> i32 ---

	// ===== Misc =====
	@(link_name = "janet_hash")
	_janet_hash :: proc(x: Janet) -> i32 ---

	@(link_name = "janet_equals")
	_janet_equals :: proc(x: Janet, y: Janet) -> i32 ---

	@(link_name = "janet_compare")
	_janet_compare :: proc(x: Janet, y: Janet) -> i32 ---

	@(link_name = "janet_length")
	_janet_length :: proc(x: Janet) -> i32 ---

	@(link_name = "janet_lengthv")
	_janet_lengthv :: proc(x: Janet) -> i32 ---

	@(link_name = "janet_get")
	_janet_get :: proc(ds: Janet, key: Janet) -> Janet ---

	@(link_name = "janet_put")
	_janet_put :: proc(ds: Janet, key: Janet, value: Janet) ---

	@(link_name = "janet_next")
	_janet_next :: proc(ds: Janet, key: Janet, out: ^Janet) -> i32 ---

	@(link_name = "janet_nextmethod")
	_janet_nextmethod :: proc(methods: ^JanetMethod, key: Janet) -> Janet ---

	@(link_name = "janet_mcall")
	_janet_mcall :: proc(method: cstring, argc: i32, argv: ^Janet) -> Janet ---

	// ===== Error handling =====
	@(link_name = "janet_panic")
	_janet_panic :: proc(message: cstring) ---

	@(link_name = "janet_panicf")
	_janet_panicf :: proc(format: cstring) ---

	@(link_name = "janet_panics")
	_janet_panics :: proc(message: JanetString) ---

	@(link_name = "janet_panicv")
	_janet_panicv :: proc(message: Janet) ---

	@(link_name = "janet_arity")
	_janet_arity :: proc(argc: i32, min: i32, max: i32) ---

	@(link_name = "janet_fixarity")
	_janet_fixarity :: proc(argc: i32, fix: i32) ---

	// ===== RNG =====
	@(link_name = "janet_default_rng")
	_janet_default_rng :: proc() -> ^JanetRNG ---

	@(link_name = "janet_rng_seed")
	_janet_rng_seed :: proc(rng: ^JanetRNG, seed: u32) ---

	@(link_name = "janet_rng_u32")
	_janet_rng_u32 :: proc(rng: ^JanetRNG) -> u32 ---

	@(link_name = "janet_rng_double")
	_janet_rng_double :: proc(rng: ^JanetRNG) -> f64 ---

	// ===== Marshal/Unmarshal =====
	@(link_name = "janet_marshal")
	_janet_marshal :: proc(buf: ^JanetBuffer, x: Janet, rreg: ^JanetTable, flags: i32) ---

	@(link_name = "janet_unmarshal")
	_janet_unmarshal :: proc(data: ^u8, len: c.size_t, flags: i32, env: ^JanetTable, next: ^^u8) -> Janet ---

	// ===== Embedding Support =====
	@(link_name = "janet_cryptorand")
	_janet_cryptorand :: proc(out: ^u8, n: c.size_t) -> i32 ---

	@(link_name = "janet_init_hash_key")
	_janet_init_hash_key :: proc(key: ^u8) ---

	@(link_name = "janet_env_lookup")
	_janet_env_lookup :: proc(env: ^JanetTable) -> ^JanetTable ---

	@(link_name = "janet_resolve_core")
	_janet_resolve_core :: proc(name: cstring) -> Janet ---

	@(link_name = "janet_cfuns_prefix")
	_janet_cfuns_prefix :: proc(env: ^JanetTable, regprefix: cstring, cfuns: ^JanetReg) ---

	@(link_name = "janet_getmethod")
	_janet_getmethod :: proc(method: JanetKeyword, methods: ^JanetMethod, out: ^Janet) -> i32 ---
}
