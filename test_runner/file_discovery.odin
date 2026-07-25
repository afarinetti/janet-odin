package main

import "core:os"
import "core:path/filepath"
import "core:sort"
import "core:strings"

// discover finds the Janet suites and examples to exercise.
//   - suites:   vendor/janet/test/suite-*.janet (flat, non-recursive)
//   - examples: vendor/janet/examples/*.janet   (flat, non-recursive; subdirs hold
//                native/bundle code that needs a separate build step)
discover :: proc() -> (suites: []string, examples: []string) {
	suites = list_matching("vendor/janet/test", "suite-", ".janet")
	examples = list_matching("vendor/janet/examples", "", ".janet")

	// Deterministic order for stable CI output.
	sort.quick_sort(suites)
	sort.quick_sort(examples)
	return
}


// list_matching returns the full paths of regular files in `dir` (non-recursive)
// whose name starts with `prefix` and ends with `suffix`.
list_matching :: proc(dir, prefix, suffix: string) -> []string {
	out: [dynamic]string
	entries, err := os.read_all_directory_by_path(dir, context.allocator)
	if err == os.ERROR_NONE {
		defer delete(entries)
		for entry in entries {
			if entry.type == .Directory do continue
			if prefix != "" && !strings.has_prefix(entry.name, prefix) do continue
			if !strings.has_suffix(entry.name, suffix) do continue
			full_path, join_err := filepath.join({dir, entry.name}, context.allocator)
			if join_err != nil do continue
			append(&out, full_path)
		}
	}
	return out[:]
}
