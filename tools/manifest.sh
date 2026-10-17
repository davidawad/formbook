#!/usr/bin/env bash
# manifest.sh: one plain-text line per leaf court (or, with --doctypes, per Typst doc type), read by the tracker.
#
# Usage: tools/manifest.sh [--doctypes] [repo-root]
#
# The logic is `fb manifest` (tools/fb, Rust); its module doc lists the line formats and flag characters:
#   courts:    alias|group|level|name|path|manual|flags   (8 flags: rules exemplars samples typst latex docx
#                                                           overlay review)
#   doc types: alias|group|doctype|path|flags             (6 flags: template samples render exemplars overlay
#                                                           review)
# Every flag keys on committed text (exemplars/SOURCE.md, samples/INPUT-*.md, typst/*.typ, samples/OVERLAY-*.txt,
# stamps, reviews), never on PDF presence, so a checkout without the PDFs gives the same manifest. Output order
# follows data/index.json.
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- manifest "$@"
