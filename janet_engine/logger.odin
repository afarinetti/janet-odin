package janet_engine

import janet "../janet"
import "core:c"
import "core:fmt"

foreign import janet_lib {"../libjanet.a", "system:c"}

// LogLevel - Janet log levels
LogLevel :: enum i32 {
	DEBUG = 0,
	INFO  = 1,
	WARN  = 2,
	ERROR = 3,
	FATAL = 4,
}

// LogFormatter - Function type for formatting log messages
LogFormatter :: proc(level: LogLevel, msg: cstring, user_data: rawptr) -> cstring

// LoggerConfig - Configuration for Janet logger
LoggerConfig :: struct {
	min_level: LogLevel,
	formatter: LogFormatter,
	user_data: rawptr,
}

// janet_logger_init - Initialize logger with configuration
janet_logger_init :: proc(cfg: LoggerConfig) -> bool {
	// Global logger state would be initialized here
	return true
}

// janet_logger_shutdown - Shutdown the logger
janet_logger_shutdown :: proc() {
	// Cleanup global logger state
}

// janet_log - Log a message at the specified level
janet_log :: proc(level: LogLevel, msg: cstring) {
	// In a full implementation, this would format and output the message
	// For now, just print to stdout
	fmt.println(cstring(msg))
}
