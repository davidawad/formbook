#!/bin/sh
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh: Times New Roman 14 pt; Body Text in 32.2 pt line boxes with a half-inch indent; List
# Item with the label in a half-inch box; footnotes 14 pt in 16.1 pt boxes, 7 pt apart; exact line spacing; typst
# pitch-double, pitch-single), plus "Body Last": the brief's last paragraph, kept with the signature block,
# and "Body Text Note": a paragraph that anchors a footnote, without widow control (typst's widow and orphan rules do
# not see the note). The cover, headings, tables, signature and certificates carry their own paragraph properties (cafc-docx.lua). Page
# setup and the footers are NOT taken from here: pandoc does not carry a reference's section properties into its
# output, so docx/render.sh writes them.
# Usage: sh docx/build-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="Times New Roman" size=28 body=644 \
  single=322 indent=720 list=720 note=322 note_size=28 note_after=140 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyLast"><w:name w:val="Body Last"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextNote"><w:name w:val="Body Text Note"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style></w:styles>} or die "styles"' word/styles.xml
xmllint --noout word/styles.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
