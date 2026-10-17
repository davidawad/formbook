#!/usr/bin/env bash
# tracker.sh: regenerate the tracker: manifest -> completion logic -> README block, STATUS.md, per-folder READMEs.
#
# Usage: tools/tracker.sh        (needs: cargo; the logic is `fb tracker` in tools/fb, Rust)
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- tracker "$@"
