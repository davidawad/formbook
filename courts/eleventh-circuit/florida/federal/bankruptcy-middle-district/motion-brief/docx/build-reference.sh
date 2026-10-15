#!/bin/sh
# Build docx/reference.docx: pandoc's default reference.docx with the pleading parts in docx/parts/ laid over it
# (styles, numbering, the document's section with the page-number footer and an empty first-page footer).
# Usage: sh docx/build-reference.sh   (needs pandoc, zip, unzip)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/default.docx"
unzip -q "$W/default.docx" -d "$W/pkg"
cp "$D"/parts/styles.xml "$D"/parts/numbering.xml "$D"/parts/document.xml "$D"/parts/footer1.xml "$D"/parts/footer2.xml "$W/pkg/word/"
REL=http://schemas.openxmlformats.org/officeDocument/2006/relationships
sed -i "s#</Relationships>#<Relationship Id=\"rIdFooter1\" Type=\"$REL/footer\" Target=\"footer1.xml\"/><Relationship Id=\"rIdFooter2\" Type=\"$REL/footer\" Target=\"footer2.xml\"/></Relationships>#" "$W/pkg/word/_rels/document.xml.rels"
CT=application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml
sed -i "s#</Types>#<Override PartName=\"/word/footer1.xml\" ContentType=\"$CT\"/><Override PartName=\"/word/footer2.xml\" ContentType=\"$CT\"/></Types>#" "$W/pkg/[Content_Types].xml"
rm -f "$D/reference.docx"
(cd "$W/pkg" && zip -q -X "$D/reference.docx" '[Content_Types].xml' && zip -q -X -r "$D/reference.docx" . -x '[Content_Types].xml')
echo "$D/reference.docx"
