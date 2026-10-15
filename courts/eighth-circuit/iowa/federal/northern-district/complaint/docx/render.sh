#!/bin/sh
# Builds the complaint .docx (docs/DOCX.md). tools/render-docx.sh calls it as: render.sh <court-dir> <sample.md> <out.docx>
# The LibreOffice PDF of that .docx is made by tools/render-docx.sh, not here.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
cd "$COURT"
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/complaint.lua" \
  "$SAMPLE" -o "$OUT"
