#!/bin/sh
# Builds the court's .docx (tools/render-docx.sh delegates here: sh docx/render.sh <court-dir> <sample.md> <out.docx>).
# pandoc writes the body with the Lua filter. pandoc 3.12 does not carry the reference's styles.xml, footer or page
# setup into the output (it writes its own defaults), so this script puts them back: the court's styles.xml, the
# page-number footer (footer1.xml, relationship rId100) and the body section (letter, one-inch margins).
# Layout values: docx/build-reference.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/nywb-adversary-complaint.lua" "$SAMPLE" -o "$W/body.docx")
mkdir "$W/pkg" "$W/ref"
(cd "$W/pkg" && unzip -q "$W/body.docx")
unzip -q -o "$D/reference.docx" -d "$W/ref"
P=$W/pkg
cp "$W/ref/word/styles.xml" "$P/word/styles.xml"
cp "$W/ref/word/footer1.xml" "$P/word/footer1.xml"
# pandoc may already carry the reference's footer relationship over: add it (and its content type) only once
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>} unless m{Id="rId100"}' "$P/word/_rels/document.xml.rels"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>} unless m{PartName="/word/footer1.xml"}' "$P/[Content_Types].xml"
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' "$P/word/document.xml"
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$P/$part"; done
rm -f "$OUT"
cd "$P"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
