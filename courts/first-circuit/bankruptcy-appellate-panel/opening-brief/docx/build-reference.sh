#!/bin/sh
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): the typst template's face at 14 pt, Body Text and List Item in 31.4 pt line boxes
# with a half-inch indent (typst pitch-double, BAP-FORM-004), Block Text and footnotes in 20 pt boxes (pitch-single),
# exact line spacing; plus one style of its own, "BAP First": a body paragraph that does not follow another
# paragraph (after a heading, a list or a quotation), which typst does not indent. bap1.lua writes the cover,
# headings, tables, signature blocks and statements as paragraphs with their own spacing; fb render
# (tools/fb/src/docxpass.rs) writes the sections' footers. The same file is in each doc-type folder.
# Usage: sh docx/build-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -eu
FONT="Times New Roman"   # the typst template's font-family (its first face)
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="$FONT" size=28 body=628 single=400 \
  indent=720 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BAPFirst"><w:name w:val="BAP First"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style></w:styles>} or die "styles"' word/styles.xml
xmllint --noout word/styles.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
