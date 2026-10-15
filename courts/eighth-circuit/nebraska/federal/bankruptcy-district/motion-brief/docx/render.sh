#!/bin/sh
# DOCX engine for motion-brief (docs/DOCX.md; tools/render-docx.sh calls this when it exists):
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc writes the document on reference.docx with nebraskab-motion-brief.lua. One fix is made after
# pandoc, because the filter cannot set it: pandoc writes the table grid of its 6.5 in text width as 5.5 in,
# so the caption and signature tables (three columns: 3.4 in, a 0.25 in gutter, 2.85 in) are set to the
# 6.5 in text width here. Needs pandoc, unzip and zip on PATH, and perl.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
case $3 in /*) OUT=$3 ;; *) OUT=$(pwd)/$3 ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/nebraskab-motion-brief.lua" "$SAMPLE" -o "$W/out.docx")
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q "$W/out.docx")
cd "$W/pkg"
# every table in these documents is the three-column caption or signature grid
perl -0pi -e 's{<w:tblGrid>.*?</w:tblGrid>}{<w:tblGrid><w:gridCol w:w="4896" /><w:gridCol w:w="360" /><w:gridCol w:w="4104" /></w:tblGrid>}sg; s{<w:tblW w:type="pct" w:w="5000" />}{<w:tblW w:type="dxa" w:w="9360" />}g' word/document.xml
xmllint --noout word/document.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" . -x '[Content_Types].xml'
