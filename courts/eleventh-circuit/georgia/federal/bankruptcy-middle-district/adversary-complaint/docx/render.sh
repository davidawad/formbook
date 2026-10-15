#!/bin/sh
# Writes the .docx of one sample (docs/DOCX.md; tools/render-docx.sh calls this and then converts the .docx with
# LibreOffice). Pandoc with docx/reference.docx and docx/gamb.lua. Pandoc's fancy lists are off: the typed labels
# "(a)", "(A)", "(i)" are text, as the typst template sets them, not list markers.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
D="$COURT/docx"
cd "$COURT"
pandoc --from markdown+smart-fancy_lists --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/gamb.lua" "$SAMPLE" -o "$OUT"
