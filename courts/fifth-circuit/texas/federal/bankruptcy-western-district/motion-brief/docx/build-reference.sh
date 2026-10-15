#!/bin/sh
# Rebuild ../reference.docx: pandoc's default reference.docx, with this folder's reference-parts/ replacing its
# styles, its section (Letter, 1 in margins, footer distance) and adding the footer part with the page number.
# Needs pandoc, unzip, zip. Run from anywhere: sh docx/build-reference.sh
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/base.docx"
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
cp "$D/reference-parts/styles.xml" "$W/x/word/styles.xml"
cp "$D/reference-parts/document.xml" "$W/x/word/document.xml"
cp "$D/reference-parts/footer1.xml" "$W/x/word/footer1.xml"
# pandoc's default has no footer part: add its relationship and content type.
sed -i 's#</Relationships>#<Relationship Id="rId100" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' "$W/x/word/_rels/document.xml.rels"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$W/x/[Content_Types].xml"
rm -f "$D/reference.docx"
(cd "$W/x" && zip -X -q "$D/reference.docx" '[Content_Types].xml' && zip -X -q -r "$D/reference.docx" _rels docProps word)
echo "$D/reference.docx"
