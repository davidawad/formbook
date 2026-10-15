#!/bin/sh
# DOCX engine for the S.D. Ohio bankruptcy adversary complaint (ohsb) (docs/DOCX.md). Called by tools/render-docx.sh:
#   sh docx/render.sh <court-dir> <sample.md> <out.docx>
# 1. pandoc, with reference.docx and the Lua filter in this folder, writes the body.
# 2. pandoc 3.6 writes its own styles.xml and does not keep the style definitions of reference.docx, so
#    reference.docx's styles.xml is put back. Every style the body, footnotes and footer use must be defined in it.
# 3. pandoc writes its own section properties and drops reference.docx's page size, margins and footer; those are
#    copied across from reference.docx.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$COURT/docx
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$W/body.docx")
mkdir "$W/ref" "$W/out"
unzip -q "$D/reference.docx" -d "$W/ref"
unzip -q "$W/body.docx" -d "$W/out"

USED=$(perl -ne 'while (/w:(?:pStyle|rStyle|tblStyle) w:val="([^"]+)"/g) { print "$1\n" }' \
  "$W/out/word/document.xml" "$W/out/word/footnotes.xml" "$W/ref/word/footer1.xml" | sort -u)
for id in $USED; do
  grep -q "w:styleId=\"$id\"" "$W/ref/word/styles.xml" || {
    echo "render.sh: style $id is used but not defined in reference.docx" >&2
    exit 1
  }
done
cp "$W/ref/word/styles.xml" "$W/out/word/styles.xml"

SECT=$(perl -0ne 'print $1 if /(<w:sectPr\b.*?<\/w:sectPr>)/s' "$W/ref/word/document.xml")
case $SECT in
  *footerReference*) ;;
  *)
    echo "render.sh: reference.docx has no footer in its section properties" >&2
    exit 1
    ;;
esac
SECT="$SECT" perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>(\s*</w:body>)}{$ENV{SECT}$1}s' "$W/out/word/document.xml"
cp "$W/ref/word/footer1.xml" "$W/out/word/footer1.xml"
grep -q 'Id="rId100"' "$W/out/word/_rels/document.xml.rels" || sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' "$W/out/word/_rels/document.xml.rels"
grep -q 'footer1.xml' "$W/out/[Content_Types].xml" || sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' "$W/out/[Content_Types].xml"
for part in word/document.xml word/styles.xml word/footer1.xml; do xmllint --noout "$W/out/$part"; done
# [Content_Types].xml alone first, then the rest (a duplicate entry name makes Word refuse the file)
(cd "$W/out" && zip -q -X "$W/final.docx" '[Content_Types].xml' && for entry in $(ls -A | grep -v '^\[Content_Types\]\.xml$'); do zip -q -X -D -r "$W/final.docx" "$entry"; done)
mv "$W/final.docx" "$OUT"
echo "$OUT"
