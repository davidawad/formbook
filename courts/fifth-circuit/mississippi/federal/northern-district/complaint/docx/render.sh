#!/bin/sh
# docx engine for the msnd complaint: pandoc with docx/reference.docx and docx/msnd-complaint.lua.
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>     (tools/render-docx.sh calls it with absolute paths)
# The CommonMark reader, because typst's markdown reader (cmarker) is CommonMark: an unindented line after a list
# item continues the item (the prayer's sub-items "b." to "d." are lines of item 2), and "3." is the next item.
# Pandoc's own markdown reader ends the list at "b." and reads the rest of the prayer as one paragraph.
# hard_line_breaks: a line break in the markdown is a line break in the document (as cmarker renders it).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
cd "$COURT"
pandoc --from commonmark+smart+hard_line_breaks+footnotes+yaml_metadata_block --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/msnd-complaint.lua" \
  "$SAMPLE" -o "$OUT"
