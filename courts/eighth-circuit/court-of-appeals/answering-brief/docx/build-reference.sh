#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: EB Garamond 14 pt, exact 31.4 pt
# (double) line spacing, first-line indent, letter page with 1 in margins, centered page number.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx
# styles: body font and size, exact double spacing, first-line indent; footnote text single 14 pt
sed -i \
  -e 's|<w:rFonts w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorEastAsia" w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi"/>|<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>|' \
  -e 's|<w:sz w:val="24"/>|<w:sz w:val="28"/>|' \
  -e 's|<w:szCs w:val="24"/>|<w:szCs w:val="28"/>|' \
  -e 's|<w:spacing w:after="200"/>|<w:spacing w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:firstLine="720"/>|' \
  word/styles.xml
# footnotes: single spaced, 14 pt
sed -i -e '/w:styleId="FootnoteText"/,/<\/w:style>/{s|<w:spacing [^/]*/>|<w:spacing w:after="100" w:line="240" w:lineRule="auto"/>|}' word/styles.xml
# custom styles for the front matter: centered, single spaced (the cover, TOC and TOA lines)
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style></w:styles>}' word/styles.xml
# footer with the page number (PAGE field, cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# body section: letter, 1 in margins, the page-number footer
sed -i 's|</w:body>|<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:body>|' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
