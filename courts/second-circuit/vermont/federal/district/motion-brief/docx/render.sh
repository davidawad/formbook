#!/bin/sh
# DOCX engine for the D. Vt. memorandum of law (docs/DOCX.md): builds <out.docx> from the markdown sample.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir or absolute> <out.docx>
# tools/render-docx.sh calls this when present; the sample path is resolved against the court dir, not the
# caller's working directory. The only source change: an asterisk before a digit is escaped. A Westlaw star
# page ("at *10") is not emphasis; pandoc would otherwise pair the asterisks into italics and drop them, and
# typst prints them. No other text is changed.
set -eu
COURT=$(cd "$1" && pwd)
case $2 in
  /*) SAMPLE=$2 ;;
  *) SAMPLE=$COURT/$2 ;;
esac
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
sed 's/\*\([0-9]\)/\\*\1/g' "$SAMPLE" > "$TMP/sample.md"
cd "$COURT"
pandoc --from markdown+smart --to docx --reference-doc="$COURT/docx/reference.docx" \
  --lua-filter="$COURT/docx/vtd-motion-brief.lua" "$TMP/sample.md" -o "$OUT"
echo "$OUT"
