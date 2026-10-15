#!/bin/sh
# DOCX build for this doc type (docs/DOCX.md): pandoc on reference.docx with every docx/*.lua filter, then two
# edits pandoc cannot express: (1) the caption's rules are cell borders (right and bottom of the left cell of the
# first table; LibreOffice does not draw paragraph borders in a table cell), and (2) every table row may not
# split across pages (the signature block stays whole, as in the typst template).
# Usage: sh docx/render.sh <doc-type-dir> <sample.md> <out.docx>   (called by tools/render-docx.sh)
set -eu
DT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D="$DT/docx"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$DT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$W/raw.docx")
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/raw.docx"
BORDER='<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
awk -v b="$BORDER" 'BEGIN { RS = "\001"; ORS = "" }
  { s = "<w:tc><w:tcPr />"; i = index($0, s)
    if (i > 0) $0 = substr($0, 1, i - 1) "<w:tc><w:tcPr>" b "</w:tcPr>" substr($0, i + length(s))
    gsub("<w:tr>", "<w:tr><w:trPr><w:cantSplit/></w:trPr>")
    print }' word/document.xml > "$W/document.xml" && mv "$W/document.xml" word/document.xml
xmllint --noout word/document.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
