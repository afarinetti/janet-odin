package janet_engine

import janet "../janet"
import "core:c"
import "core:os"

foreign import janet_lib {"../libjanet.a", "system:c"}

// HotReloadConfig - Configuration for hot-reload manager
HotReloadConfig :: struct {
	watch_dir:          string,
	file_pattern:       string, // e.g. "*.janet"
	poll_interval_ms:   u32,
	compile_timeout_ms: u32, // 0 = no timeout
}

// HotReloadEvent - Events from hot-reload manager
HotReloadEvent :: enum i32 {
	LOADED   = 0,
	ERROR    = 1,
	UNLOADED = 2,
}

// WatchedFile - A file being watched for changes
WatchedFile :: struct {
	path:     string,
	mtime:    i64,
	func_ref: janet.JanetFunction,
}

// HotReloadState - Internal state for hot-reload manager
HotReloadState :: struct {
	eng:     ^JanetEngine,
	files:   [dynamic]WatchedFile,
	poll_ms: u32,
	cfg:     HotReloadConfig,
	events:  [dynamic]HotReloadEvent,
}

// janet_hotreload_init - Initialize hot-reload manager
janet_hotreload_init :: proc(eng: ^JanetEngine, cfg: HotReloadConfig) -> (^HotReloadState, bool) {
	state := new(HotReloadState)
	state.eng = eng
	state.cfg = cfg
	state.poll_ms = cfg.poll_interval_ms
	state.events = make([dynamic]HotReloadEvent, 0)
	state.files = make([dynamic]WatchedFile, 0)
	return state, true
}

// janet_hotreload_shutdown - Shutdown hot-reload manager
janet_hotreload_shutdown :: proc(state: ^HotReloadState) {
	if state != nil {
		delete(state.events)
		delete(state.files)
		free(state)
	}
}

// janet_hotreload_poll - Check for file changes and reload
// Returns array of events that occurred
janet_hotreload_poll :: proc(state: ^HotReloadState) -> []HotReloadEvent {
	// Clear previous events
	clear(&state.events)

	// For now, just return empty - full implementation would check mtimes
	// and recompile changed files
	return state.events[:]
}

// janet_hotreload_reload - Manually trigger reload of a specific file
janet_hotreload_reload :: proc(state: ^HotReloadState, path: string) -> bool {
	// Read file content
	data, err := os.read_entire_file_from_path(path, context.allocator)
	if err != nil {
		return false
	}
	defer delete(data)

	// Would compile using janet_dostring here
	// For now, just return true indicating file was read
	return true
}
