#!/bin/sh
# Build docx/reference.docx: pandoc's default reference.docx with this folder's parts swapped in.
# Parts: docx/reference-parts/word/{styles,numbering,document,footer1}.xml. Package wiring (footer relationship and
# content type) is spliced into pandoc's own rels and [Content_Types].xml, so the rest of the package is pandoc's.
# Usage: sh docx/make-reference.sh   (run from anywhere; needs pandoc, zip, unzip)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/default.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q "$W/default.docx")
for p in styles numbering document footer1; do
  cp "$D/reference-parts/word/$p.xml" "$W/pkg/word/$p.xml"
done
sed -i 's#</Relationships>#<Relationship Id="rIdFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' "$W/pkg/word/_rels/document.xml.rels"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$W/pkg/[Content_Types].xml"
rm -f "$D/reference.docx"
(cd "$W/pkg" && zip -X -q "$D/reference.docx" '[Content_Types].xml' && zip -X -q -r "$D/reference.docx" . -x '[Content_Types].xml')
echo "$D/reference.docx"
