#!/bin/sh
# DOCX engine for the E.D. La. memorandum supporting a motion (docs/DOCX.md). tools/render-docx.sh hands the .docx
# to this script:
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc reads the sample with fancy lists off ("A. " is a lettered item, not a list) and builds the document on
# reference.docx with laed-motion-brief.lua. The PDF of it is made by tools/render-docx.sh (LibreOffice).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
cd "$COURT"
pandoc --from markdown+smart-fancy_lists --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/laed-motion-brief.lua" "$SAMPLE" -o "$OUT"
