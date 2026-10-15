#!/bin/sh
# Build docx/reference.docx: pandoc's default reference docx with this folder's styles, page setup and footer.
# Usage: sh docx/make-reference.sh <heading-variant: complaint|motion>
# Needs pandoc, zip and unzip. Parts live in docx/reference-src/. Rerunning rewrites reference.docx.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
VARIANT=${1:?usage: make-reference.sh complaint|motion}
SRC=$HERE/reference-src
case $VARIANT in
  complaint) H2JC='<w:jc w:val="center"/>' H3IND='' ;;   # complaint: centered level-2 headings
  motion) H2JC='' H3IND='<w:ind w:left="720"/>' ;;      # motion brief: left-aligned level-2, indented level-3
  *) echo "make-reference.sh: unknown variant $VARIANT" >&2; exit 2 ;;
esac
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
pandoc --print-default-data-file reference.docx > "$WORK/default.docx"
mkdir "$WORK/pkg"
unzip -q "$WORK/default.docx" -d "$WORK/pkg"
# Replace the default styles and body; keep numbering, settings, theme, fonts, footnote and comment parts.
sed -e "s|@@H2JC@@|$H2JC|" -e "s|@@H3IND@@|$H3IND|" "$SRC/styles.xml" > "$WORK/pkg/word/styles.xml"
cp "$SRC/document.xml" "$WORK/pkg/word/document.xml"
cp "$SRC/footer1.xml" "$WORK/pkg/word/footer1.xml"
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /></Relationships>|' "$WORK/pkg/word/_rels/document.xml.rels"
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' "$WORK/pkg/[Content_Types].xml"
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$WORK/pkg/$part"; done
rm -f "$HERE/reference.docx"
(cd "$WORK/pkg" && zip -q -X -r "$HERE/reference.docx" '[Content_Types].xml' _rels docProps word)
echo "$HERE/reference.docx"
