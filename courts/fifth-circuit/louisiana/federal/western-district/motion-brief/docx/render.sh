#!/bin/sh
# The motion-brief docx build (tools/render-docx.sh calls this when it exists; see docs/DOCX.md).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# 1. pandoc writes the .docx from docx/reference.docx and docx/lawd-motion-brief.lua.
# 2. The front matter's section needs a footer part and relationship that pandoc does not write: the footer is
#    the reference's footer part (PAGE, centered) copied to footer2.xml, related as rIdFooterRoman. The page-number
#    format (lowerRoman for the front, decimal from 1 for the body) is in the sectPr of each section.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in
  /*) ;;
  *) OUT=$PWD/$OUT ;;
esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/lawd-motion-brief.lua" "$SAMPLE" -o "$T/out.docx") || exit 1
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/out.docx")
X="$T/x"
grep -q 'Target="footer1.xml"' "$X/word/_rels/document.xml.rels" || { echo "render.sh: pandoc wrote no footer1.xml relationship" >&2; exit 1; }
cp "$X/word/footer1.xml" "$X/word/footer2.xml"
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooterRoman" Target="footer2.xml" />$1}s' "$X/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$X/[Content_Types].xml"
grep -q 'rIdFooterRoman' "$X/word/document.xml" || { echo "render.sh: the front section does not reference rIdFooterRoman" >&2; exit 1; }
xmllint --noout "$X/word/footer2.xml" "$X/word/_rels/document.xml.rels" "$X/[Content_Types].xml"
rm -f "$OUT"
(cd "$X" && zip -X -q "$OUT" '[Content_Types].xml' && zip -X -q -r "$OUT" . -x '[Content_Types].xml')
echo "$OUT"
