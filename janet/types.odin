package janet

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

// JanetValue union - nanboxed union matching Janet's union Janet
// On 64-bit platforms, Janet uses NANBOX_64 encoding
Janet :: struct #raw_union {
	u64:     u64,
	i64:     i64,
	number:  f64,
	pointer: rawptr,
}

// Opaque VM type
JanetVM :: struct {
}

// GC-managed types (opaque pointers)
JanetFunction :: struct {
}
JanetArray :: struct {
}
JanetBuffer :: struct {
}
JanetTable :: struct {
}
JanetFiber :: struct {
}
JanetCFunction :: proc "c" (argc: i32, argv: [^]Janet) -> Janet

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
