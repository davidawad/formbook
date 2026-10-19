#!/usr/bin/env bash
# overlay.sh: overlay a rendered sample on its FILED-EXAMPLE, page by page (red = ours, blue = filed, black = both).
# Usage: tools/overlay.sh <doc-dir> <id> [FILED-EXAMPLE.pdf]   (<id> = <doctype>[-<n>])
# The logic is `fb overlay` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- overlay "$@"
