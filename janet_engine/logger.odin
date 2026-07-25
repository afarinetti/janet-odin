package janet_engine

import janet_low "../janet_low"
import "core:c"
import "core:fmt"

// LogLevel - Log levels for the Janet engine
LogLevel :: enum i32 {
	DEBUG = 0,
	INFO  = 1,
	WARN  = 2,
	ERROR = 3,
	FATAL = 4,
}

// Logger state
logger_min_level: LogLevel = LogLevel.INFO

// janet_logger_init - Initialize the logger with a minimum log level
janet_logger_init :: proc(min_level: LogLevel) {
	logger_min_level = min_level
}

// janet_logger_shutdown - Shutdown the logger (cleanup if needed)
janet_logger_shutdown :: proc() {
	// No cleanup needed for simple logger
}

// janet_set_log_level - Set the minimum log level
janet_set_log_level :: proc(level: LogLevel) {
	logger_min_level = level
}

// janet_get_log_level - Get the current minimum log level
janet_get_log_level :: proc() -> LogLevel {
	return logger_min_level
}

// janet_log - Log a message at the specified level
janet_log :: proc(level: LogLevel, msg: cstring) {
	if level >= logger_min_level {
		level_str: cstring
		if level == LogLevel.DEBUG {
			level_str = "DEBUG"
		} else if level == LogLevel.INFO {
			level_str = "INFO"
		} else if level == LogLevel.WARN {
			level_str = "WARN"
		} else if level == LogLevel.ERROR {
			level_str = "ERROR"
		} else if level == LogLevel.FATAL {
			level_str = "FATAL"
		}
		fmt.eprintf("[%s] %s\n", level_str, msg)
	}
}

// janet_logf - Log a formatted message at the specified level
janet_logf :: proc(level: LogLevel, format: cstring) {
	if level >= logger_min_level {
		level_str: cstring
		if level == LogLevel.DEBUG {
			level_str = "DEBUG"
		} else if level == LogLevel.INFO {
			level_str = "INFO"
		} else if level == LogLevel.WARN {
			level_str = "WARN"
		} else if level == LogLevel.ERROR {
			level_str = "ERROR"
		} else if level == LogLevel.FATAL {
			level_str = "FATAL"
		}
		fmt.eprintf("[%s] ", level_str)
		// Note: Janet's janet_printf would be ideal here, but it requires
		// variadic C functions which Odin doesn't directly support
		fmt.eprintf("%s\n", format)
	}
}

// Helper functions for common log levels
janet_log_debug :: proc(msg: cstring) {
	janet_log(LogLevel.DEBUG, msg)
}

janet_log_info :: proc(msg: cstring) {
	janet_log(LogLevel.INFO, msg)
}

janet_log_warn :: proc(msg: cstring) {
	janet_log(LogLevel.WARN, msg)
}

janet_log_error :: proc(msg: cstring) {
	janet_log(LogLevel.ERROR, msg)
}

janet_log_fatal :: proc(msg: cstring) {
	janet_log(LogLevel.FATAL, msg)
}
