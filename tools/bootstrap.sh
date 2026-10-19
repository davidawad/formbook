#!/usr/bin/env bash
# bootstrap.sh: install the formbook toolchain without root (micromamba + conda-forge) and verify every tool.
# Usage: tools/bootstrap.sh [--check]     (--check verifies only; installs nothing)
# The logic is `fb bootstrap` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- bootstrap "$@"
