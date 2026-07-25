package janet_low

// janet_function attribute - proc attribute for Janet binding registration
// Usage: @(janet_function("name", "summary"))
// This is a marker attribute for code generators and documentation
janet_function :: struct {
	name:    string,
	summary: string,
}
