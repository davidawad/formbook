#!/bin/sh
# Writes the Word document of one sample: pandoc with docx/reference.docx and docx/flsb-motion-brief.lua.
# Called by tools/render-docx.sh, which converts the .docx to PDF with LibreOffice (docs/DOCX.md).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in
  /*) ;;
  *) OUT=$PWD/$OUT ;;
esac
D="$COURT/docx"
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/flsb-motion-brief.lua" "$SAMPLE" -o "$OUT")
echo "$OUT"
