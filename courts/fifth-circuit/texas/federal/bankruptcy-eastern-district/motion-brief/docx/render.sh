#!/bin/sh
# DOCX engine for the motion (docs/DOCX.md). tools/render-docx.sh calls this as
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc reads the sample with the txeb Lua filter and reference.docx (the footer page number is in reference.docx).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
# -tex_math_dollars: "$" is a dollar amount; -definition_lists: "~" opens a paragraph, not a definition; -fancy_lists: "(c)" and "(1)" open a paragraph, not a list
(cd "$COURT" && pandoc --from=markdown-tex_math_dollars-definition_lists-fancy_lists-raw_html+smart --to=docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/txeb-motion-brief.lua" \
  "$SAMPLE" -o "$OUT")
