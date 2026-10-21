#!/usr/bin/env bash
# check-selftest.sh: does the checker actually catch defects? Mutation test for `fb check`.
# Usage: tools/check-selftest.sh <court-dir>
# The logic is `fb check-selftest` (tools/fb, Rust); this wrapper only builds and runs it.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- selftest "$@"
