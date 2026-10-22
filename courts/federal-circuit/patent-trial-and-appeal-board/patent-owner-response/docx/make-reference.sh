#!/bin/sh
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt; Body Text in 32 pt exact line boxes (double spacing,
# PTAB-POR-FORM-003) with a half-inch first-line indent; List Item with the label in a half-inch box; footnotes 14 pt
# in 16 pt boxes, 7 pt apart (typst pitch-double, pitch-single, footnote.entry gap). Plus one style of its own,
# "Body Keep": the body's last paragraph, kept on the page of the signature block. The cover, contents, headings,
# signature and certificates are written by ptab-patent-owner-response.lua with their own exact spacing (twips = 20 x
# the typst pt). Page setup and footers are written by docx/render.sh (pandoc does not carry them over).
# Usage: sh docx/make-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="Times New Roman" size=28 body=640 \
  single=320 indent=720 list=720 note_after=140 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style></w:styles>} or die "styles"' word/styles.xml
xmllint --noout word/styles.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
