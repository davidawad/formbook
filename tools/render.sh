#!/usr/bin/env bash
# render.sh: render one sample to PDF with the doc folder's typst template (default) or another engine.
# Any typst warning fails the typst render.
# Usage: tools/render.sh [--engine typst|latex|docx] <doc-dir> <sample.md (relative to doc dir or absolute)> [out.pdf]
# The logic is `fb render` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- render --deny-warnings "$@"
