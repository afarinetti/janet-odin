#!/usr/bin/env bash
# Build Janet as a static library (libjanet.a) at the repo root for the Odin bindings.
# Single source of truth used by both CI and local devs. Mirrors wren-odin/build_wren.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

JANET_SRC="vendor/janet"
JANET_BUILD="$JANET_SRC/build"

echo "=== Building Janet static library ==="

# Configure with meson on a fresh checkout; reuse an existing build dir otherwise
# (meson refuses to re-setup into an already-configured directory).
if [ ! -f "$JANET_BUILD/build.ninja" ]; then
	echo "Configuring meson build..."
	meson setup "$JANET_BUILD" "$JANET_SRC"
else
	echo "Build dir already configured; rebuilding..."
fi

# Compile the static library.
ninja -C "$JANET_BUILD"

# Stage it at the repo root — the Odin foreign imports resolve "../libjanet.a".
if [ ! -f "$JANET_BUILD/libjanet.a" ]; then
	echo "ERROR: $JANET_BUILD/libjanet.a was not produced."
	echo "       If the build dir is stale, run: rm -rf $JANET_BUILD && ./build_janet.sh"
	exit 1
fi
cp "$JANET_BUILD/libjanet.a" ./libjanet.a
echo "  -> ./libjanet.a ($(wc -c < ./libjanet.a) bytes)"

# Verify core symbols are present (macOS nm prefixes with _).
echo ""
echo "Verifying symbols..."
SYMBOL_COUNT=$(nm ./libjanet.a 2>/dev/null | grep -cE " T _?janet_(init|core_env|dostring)" || true)
echo "  Found $SYMBOL_COUNT core janet symbols (init/core_env/dostring)"

if [ "$SYMBOL_COUNT" -lt 3 ]; then
	echo "ERROR: Expected at least 3 core janet symbols, found $SYMBOL_COUNT"
	exit 1
fi

echo ""
echo "=== Build complete ==="
