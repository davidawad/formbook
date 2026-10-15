#!/bin/sh
# DOCX engine for this court's opening-brief (docs/EVAL-LOOP.md, "Engines"): writes the .docx only; tools/render-docx.sh
# then converts it to PDF with LibreOffice and checks the zip and XML parts.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Markdown is read with smart punctuation off (as typst does), so "..." dot leaders and straight quotes stay as typed.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
cd "$COURT" && pandoc --from markdown-smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/brief.lua" "$SAMPLE" -o "$OUT"
