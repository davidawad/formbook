#!/bin/sh
# Builds one sample with the flnb motion-brief Word template (docs/EVAL-LOOP.md, "Engines"): pandoc writes the
# body with reference.docx and flnb-motion-brief.lua. Lettered sub-items ("a)") stay paragraphs (no fancy lists),
# as in the typst template. Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D="$COURT/docx"
(cd "$COURT" && pandoc --from markdown-fancy_lists+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/flnb-motion-brief.lua" "$SAMPLE" -o "$OUT")
echo "$OUT"
