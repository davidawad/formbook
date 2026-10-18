#!/usr/bin/env bash
# manifest.sh: one plain-text line per leaf court (or, with --doctypes, per Typst doc type), read by the tracker.
#
# Usage: tools/manifest.sh [--doctypes] [repo-root]
#
# The logic is `fb manifest` (tools/fb, Rust); its module doc lists the line formats and flag characters:
#   courts:    alias|group|level|name|path|manual|flags   (flags: rules sources inputs typst latex docx review)
#   doc types: alias|group|doctype|path|flags             (flags: template inputs render sources review)
# Every flag keys on committed text (usage/SOURCE.md, usage/INPUT-*.md, typst/*.typ, usage/ stamps, reviews),
# never on PDF presence, so a checkout without the PDFs gives the same manifest. Overlays are not committed
# (they live in the gitignored .overlay/) and are not a flag. Output order
# follows data/index.json.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- manifest "$@"
