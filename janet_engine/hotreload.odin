package janet_engine

import janet_low "../janet_low"
import "core:c"
import "core:os"
import "core:time"

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
	func_ref: janet_low.Janet,
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

// get_file_mtime - Get file modification time
get_file_mtime :: proc(path: string) -> (i64, bool) {
	info, err := os.stat(path, context.allocator)
	if err != nil {
		return 0, false
	}
	return info.modification_time._nsec, true
}

// janet_hotreload_poll - Check for file changes and reload
// Returns array of events that occurred
janet_hotreload_poll :: proc(state: ^HotReloadState) -> []HotReloadEvent {
	// Clear previous events
	clear(&state.events)

	// Check each watched file for changes
	for i in 0 ..< len(state.files) {
		file := &state.files[i]
		mtime, ok := get_file_mtime(file.path)
		if !ok {
			// File no longer exists or can't be accessed
			append(&state.events, HotReloadEvent.UNLOADED)
			continue
		}

		// Check if file was modified
		if mtime > file.mtime {
			// File changed, reload it
			if janet_hotreload_reload(state, file.path) {
				file.mtime = mtime
				append(&state.events, HotReloadEvent.LOADED)
			} else {
				append(&state.events, HotReloadEvent.ERROR)
			}
		}
	}

	return state.events[:]
}

// janet_hotreload_reload - Manually trigger reload of a specific file
janet_hotreload_reload :: proc(state: ^HotReloadState, path: string) -> bool {
	// Read file content
	data, err := os.read_entire_file_from_path(path, context.allocator)
	if err != nil {
		janet_log_error("Failed to read file for reload")
		return false
	}
	defer delete(data)

	// Compile the Janet code
	result: janet_low.Janet
	status := janet_low.janet_dostring(
		state.eng.env,
		transmute(cstring)raw_data(data),
		transmute(cstring)raw_data(path),
		&result,
	)

	if status != 0 {
		janet_log_error("Failed to compile Janet code")
		return false
	}

	// Check if we already have this file watched
	found := false
	for i in 0 ..< len(state.files) {
		if state.files[i].path == path {
			state.files[i].func_ref = result
			mtime, _ := get_file_mtime(path)
			state.files[i].mtime = mtime
			found = true
			break
		}
	}

	// If not watched yet, add it
	if !found {
		mtime, _ := get_file_mtime(path)
		watched := WatchedFile {
			path     = path,
			mtime    = mtime,
			func_ref = result,
		}
		append(&state.files, watched)
	}

	janet_log_info("Successfully reloaded Janet file")
	return true
}

// janet_hotreload_watch - Add a file to the watch list
janet_hotreload_watch :: proc(state: ^HotReloadState, path: string) -> bool {
	// Check if already watching
	for file in state.files {
		if file.path == path {
			return true // Already watching
		}
	}

	// Get initial modification time
	mtime, ok := get_file_mtime(path)
	if !ok {
		return false
	}

	// Add to watch list
	watched := WatchedFile {
		path     = path,
		mtime    = mtime,
		func_ref = janet_low.janet_wrap_nil(),
	}
	append(&state.files, watched)
	return true
}

// janet_hotreload_unwatch - Remove a file from the watch list
janet_hotreload_unwatch :: proc(state: ^HotReloadState, path: string) {
	for i in 0 ..< len(state.files) {
		if state.files[i].path == path {
			// Remove by swapping with last element
			state.files[i] = state.files[len(state.files) - 1]
			pop(&state.files)
			return
		}
	}
}
