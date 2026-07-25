package janet_low

// JanetType enum - matches Janet's JanetType enum in janet.h
JanetType :: enum i32 {
	NUMBER    = 0,
	NIL       = 1,
	BOOLEAN   = 2,
	FIBER     = 3,
	STRING    = 4,
	SYMBOL    = 5,
	KEYWORD   = 6,
	ARRAY     = 7,
	TUPLE     = 8,
	TABLE     = 9,
	STRUCT    = 10,
	BUFFER    = 11,
	FUNCTION  = 12,
	CFUNCTION = 13,
	ABSTRACT  = 14,
	POINTER   = 15,
}

// Type count
JANET_COUNT_TYPES :: 16

// Type flags - use integer values directly since enum members need type qualification
JANET_TFLAG_NIL :: 1 << 1
JANET_TFLAG_BOOLEAN :: 1 << 2
JANET_TFLAG_FIBER :: 1 << 3
JANET_TFLAG_NUMBER :: 1 << 0
JANET_TFLAG_STRING :: 1 << 4
JANET_TFLAG_SYMBOL :: 1 << 5
JANET_TFLAG_KEYWORD :: 1 << 6
JANET_TFLAG_ARRAY :: 1 << 7
JANET_TFLAG_TUPLE :: 1 << 8
JANET_TFLAG_TABLE :: 1 << 9
JANET_TFLAG_STRUCT :: 1 << 10
JANET_TFLAG_BUFFER :: 1 << 11
JANET_TFLAG_FUNCTION :: 1 << 12
JANET_TFLAG_CFUNCTION :: 1 << 13
JANET_TFLAG_ABSTRACT :: 1 << 14
JANET_TFLAG_POINTER :: 1 << 15

// Compound flags
JANET_TFLAG_BYTES ::
	JANET_TFLAG_STRING | JANET_TFLAG_SYMBOL | JANET_TFLAG_BUFFER | JANET_TFLAG_KEYWORD
JANET_TFLAG_INDEXED :: JANET_TFLAG_ARRAY | JANET_TFLAG_TUPLE
JANET_TFLAG_DICTIONARY :: JANET_TFLAG_TABLE | JANET_TFLAG_STRUCT
JANET_TFLAG_LENGTHABLE :: JANET_TFLAG_BYTES | JANET_TFLAG_INDEXED | JANET_TFLAG_DICTIONARY
JANET_TFLAG_CALLABLE ::
	JANET_TFLAG_FUNCTION | JANET_TFLAG_CFUNCTION | JANET_TFLAG_LENGTHABLE | JANET_TFLAG_ABSTRACT

// JanetSignal enum - fiber signals
JanetSignal :: enum i32 {
	OK        = 0,
	ERROR     = 1,
	DEBUG     = 2,
	YIELD     = 3,
	USER0     = 4,
	USER1     = 5,
	USER2     = 6,
	USER3     = 7,
	USER4     = 8,
	USER5     = 9,
	USER6     = 10,
	USER7     = 11,
	USER8     = 12,
	USER9     = 13,
	INTERRUPT = 12, // alias for USER8
	EVENT     = 13, // alias for USER9
}

// JanetFiberStatus enum - fiber statuses
JanetFiberStatus :: enum i32 {
	DEAD    = 0,
	ERROR   = 1,
	DEBUG   = 2,
	PENDING = 3,
	USER0   = 8,
	USER1   = 9,
	USER2   = 10,
	USER3   = 11,
	USER4   = 12,
	USER5   = 13,
	USER6   = 14,
	USER7   = 15,
	USER8   = 16,
	USER9   = 17,
	NEW     = 18,
	ALIVE   = 19,
}

// JanetBindingType enum - returned by janet_resolve
JanetBindingType :: enum i32 {
	NONE          = 0,
	VARIABLE      = 1,
	DEF           = 2,
	MACRO         = 3,
	DYNAMIC_DEF   = 4,
	DYNAMIC_MACRO = 5,
}

// Janet - The core Janet value type
// On ARM64 (non-nanbox), this is a struct with union + type tag
// On x86_64 (nanbox), this would be a raw union
Janet :: struct {
	as:   JanetUnion,
	type: JanetType,
}

JanetUnion :: struct #raw_union {
	u64:      u64,
	i64:      i64,
	number:   f64,
	integer:  i32,
	pointer:  rawptr,
	cpointer: rawptr,
}

// Opaque VM type
JanetVM :: struct {
}

// GC object header - all GC-managed types start with this
JanetGCObject :: struct {
	flags: i32,
	data:  rawptr, // union: next pointer or refcount
}

// GC-managed types
JanetFunction :: struct {
	gc:  JanetGCObject,
	def: ^JanetFuncDef,
}

JanetFuncDef :: struct {
	gc:             JanetGCObject,
	environments:   ^i32,
	constants:      ^Janet,
	defs:           ^^JanetFuncDef,
	bytecode:       ^u32,
	closure_bitset: ^u32,
	sourcemap:      rawptr,
	source:         JanetString,
	name:           JanetString,
	min_arity:      i32,
	max_arity:      i32,
	slotcount:      i32,
	flags:          u32,
}

JanetArray :: struct {
	gc:       JanetGCObject,
	count:    i32,
	capacity: i32,
	data:     ^Janet,
}

JanetBuffer :: struct {
	gc:       JanetGCObject,
	count:    i32,
	capacity: i32,
	data:     ^u8,
}

JanetTable :: struct {
	gc:       JanetGCObject,
	count:    i32,
	capacity: i32,
	deleted:  i32,
	data:     ^JanetKV,
	proto:    ^JanetTable,
}

JanetFiber :: struct {
	gc:         JanetGCObject,
	flags:      i32,
	frame:      i32,
	stackstart: i32,
	stacktop:   i32,
	capacity:   i32,
	maxstack:   i32,
	env:        ^JanetTable,
	data:       ^Janet,
	child:      ^JanetFiber,
	last_value: Janet,
}

JanetCFunction :: proc "c" (argc: i32, argv: ^Janet) -> Janet

// String types (const uint8_t*)
JanetString :: distinct ^u8
JanetSymbol :: distinct ^u8
JanetKeyword :: distinct ^u8

// Composite types
JanetTuple :: ^Janet // const Janet*
JanetStruct :: ^JanetKV // const JanetKV*
JanetAbstract :: rawptr
JanetPointer :: rawptr

// Key-value pair for tables/structs
JanetKV :: struct {
	key:   Janet,
	value: Janet,
}

// JanetStructHead - Header for struct values (immutable tables)
JanetStructHead :: struct {
	gc:       JanetGCObject,
	length:   i32,
	hash:     i32,
	capacity: i32,
	proto:    ^JanetTable,
	data:     [0]JanetKV,
}

// JanetStringHead - Header for string values
JanetStringHead :: struct {
	gc:     JanetGCObject,
	length: i32,
	hash:   i32,
	data:   [0]u8,
}

// JanetTupleHead - Header for tuple values
JanetTupleHead :: struct {
	gc:        JanetGCObject,
	length:    i32,
	hash:      i32,
	sm_line:   i32,
	sm_column: i32,
	data:      [0]Janet,
}


// Abstract type definition
JanetAbstractType :: struct {
	name:      cstring,
	finalizer: proc "c" (data: rawptr, len: i32),
	gcmark:    proc "c" (data: rawptr, len: i32),
	migrate:   proc "c" (data: rawptr, len: i32),
	format:    proc "c" (data: rawptr, len: i32, buf: ^JanetBuffer),
	compare:   proc "c" (a: rawptr, b: rawptr) -> i32,
	hash:      proc "c" (data: rawptr, len: i32) -> i32,
	marshal:   proc "c" (data: rawptr, len: i32, buf: ^JanetBuffer),
	unmarshal: proc "c" (data: rawptr, len: i32, buf: ^JanetBuffer) -> rawptr,
	tostring:  proc "c" (data: rawptr, len: i32, buf: ^JanetBuffer),
}

// Function registration
JanetReg :: struct {
	name: cstring,
	cfun: JanetCFunction,
	doc:  cstring,
}

// Parser state
JanetParser :: struct {
	// Opaque parser state
	_: [0]u8,
}

// Method definition
JanetMethod :: struct {
	name: cstring,
	cfun: JanetCFunction,
}

// Random number generator
JanetRNG :: struct {
	a: u64,
	b: u64,
	c: u64,
	d: u64,
}

// JanetBinding - returned by janet_resolve_ext
JanetBinding :: struct {
	type:        JanetBindingType,
	value:       Janet,
	deprecation: i32,
}
