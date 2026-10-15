#!/bin/sh
# nynd complaint, DOCX engine: builds the .docx for one sample (docs/DOCX.md).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Called by tools/render-docx.sh, which then converts the .docx to the LibreOffice PDF.
# The markdown is read as CommonMark (commonmark_x, as cmarker reads it in typst): a literal "*" is not emphasis.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
[ -f "$D/reference.docx" ] || { echo "render.sh: missing $D/reference.docx (run docx/build-reference.sh)" >&2; exit 1; }
pandoc --from commonmark_x-fancy_lists+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/nynd-complaint.lua" "$COURT/$SAMPLE" -o "$OUT"
echo "$OUT"
