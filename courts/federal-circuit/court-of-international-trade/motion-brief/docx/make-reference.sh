#!/usr/bin/env bash
# Build docx/reference.docx for the CIT motion-brief on the shared cross-engine style recipe
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt; Body Text at the
# 24 pt body pitch with a 0.5 in first-line indent; List Item with the label in a 0.5 in box; Block Text single spaced
# (14 pt), indented 0.5 in both sides, 14 pt above and below; footnotes 12 pt at 14 pt, 7 pt apart; letter paper,
# 1 in margins. The same numbers as typst/cit-motion-brief.typ (pitch, pitch-single, para-indent, space-quote,
# note-gap). The filter writes the headings, covers, tables and signature blocks with their own spacing; fb render
# writes the footers (docxpass.rs).
# Usage: sh make-reference.sh [<out.docx>]   (needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" font="Times New Roman" size=24 \
  body=480 single=280 indent=720 list=720 heading=280 heading_before=480 heading_after=240 quote=280 note_after=140 \
  footer=730
