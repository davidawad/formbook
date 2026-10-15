#!/bin/sh
# docx engine for the msnd motion brief: pandoc with docx/reference.docx and docx/msnd-motion-brief.lua.
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>     (tools/render-docx.sh calls it with absolute paths)
# The CommonMark reader, because typst's markdown reader (cmarker) is CommonMark; pandoc's own markdown reader
# reads some list continuations differently (see ../../complaint/docx/render.sh). hard_line_breaks: a line break in
# the markdown is a line break in the document.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
cd "$COURT"
pandoc --from commonmark+smart+hard_line_breaks+footnotes+yaml_metadata_block --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/msnd-motion-brief.lua" \
  "$SAMPLE" -o "$OUT"
