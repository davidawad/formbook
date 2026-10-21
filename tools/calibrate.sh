#!/usr/bin/env bash
# calibrate.sh: the word-compat calibration run (fb-w0vj, docs/EVAL-LOOP.md "Word compatibility").
# Usage: tools/calibrate.sh [--engine typst|latex] [--no-render] [entry-dir-substring]
# The logic is `fb calibrate` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- calibrate "$@"
