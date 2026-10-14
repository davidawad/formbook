#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx and the parts in docx/reference-src/ (styles,
# footers, page setup). Rerun after editing reference-src/. The reply brief has no addendum, so there is one
# reference: the body's and front matter's footers are arabic and roman numbers from footer1.xml.
# Needs: pandoc, unzip, zip (the formbook toolchain plus unzip and zip on PATH).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
S=$D/reference-src
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc -o "$T/default.docx" --print-default-data-file reference.docx

W=$T/w
mkdir -p "$W"
(cd "$W" && unzip -q "$T/default.docx")
cp "$S/styles.xml" "$W/word/styles.xml"
cp "$S/footer0.xml" "$S/footer1.xml" "$W/word/"
# Word 2013+ layout rules (tab stops measured from the margin, as LibreOffice needs for the TOC)
sed -i "s#<w:rsids>#<w:compat><w:compatSetting w:name=\"compatibilityMode\" w:uri=\"http://schemas.microsoft.com/office/word\" w:val=\"15\"/></w:compat><w:rsids>#" "$W/word/settings.xml"
R=http://schemas.openxmlformats.org/officeDocument/2006/relationships
sed -i "s#</Relationships>#<Relationship Type=\"$R/footer\" Id=\"rIdFtr0\" Target=\"footer0.xml\" /><Relationship Type=\"$R/footer\" Id=\"rIdFtr1\" Target=\"footer1.xml\" /></Relationships>#" "$W/word/_rels/document.xml.rels"
M=application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml
sed -i "s#</Types>#<Override PartName=\"/word/footer0.xml\" ContentType=\"$M\" /><Override PartName=\"/word/footer1.xml\" ContentType=\"$M\" /></Types>#" "$W/[Content_Types].xml"
SECT="<w:sectPr><w:footerReference w:type=\"default\" r:id=\"rIdFtr1\" /><w:pgSz w:w=\"12240\" w:h=\"15840\" /><w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\" /><w:pgNumType w:fmt=\"decimal\" w:start=\"1\" /></w:sectPr>"
tr -d '\n' < "$W/word/document.xml" | sed "s#<w:sectPr>.*</w:sectPr>#$SECT#" > "$W/word/document.xml.new"
mv "$W/word/document.xml.new" "$W/word/document.xml"
rm -f "$D/reference.docx"
(cd "$W" && zip -q -X -r "$D/reference.docx" '[Content_Types].xml' _rels docProps word)
echo "$D/reference.docx"
