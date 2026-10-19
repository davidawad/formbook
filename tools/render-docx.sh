#!/usr/bin/env bash
# render-docx.sh: render one sample to .docx and to the LibreOffice PDF of it (engine "docx").
# Usage: tools/render-docx.sh <doc-dir> <usage/INPUT-<id>.md, relative to the doc dir> [out.docx.pdf]
# The logic is `fb render --engine docx` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- render --engine docx "$@"
