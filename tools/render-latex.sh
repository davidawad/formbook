#!/usr/bin/env bash
# render-latex.sh: render one sample with the court's LaTeX template (engine "latex").
# Usage: tools/render-latex.sh <doc-dir> <usage/INPUT-<id>.md, relative to the doc dir> [out.pdf]
# The logic is `fb render --engine latex` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- render --engine latex "$@"
