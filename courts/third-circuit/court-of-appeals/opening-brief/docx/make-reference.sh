#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt (the typst template's font); Body Text and List Item in
# 31.4 pt line boxes (typst pitch-double, FRAP 32(a)(4)) with a half-inch indent; quotations, footnotes and the heading
# styles in 20 pt boxes (typst pitch-single), quotations 14 pt above and below, 7 pt after each footnote (ca3.lua sets
# every heading's own spacing; the styles give the outline levels). Page setup and footers come from ca3.lua's sections
# and fb render. One style is added: Body Text Noted, Body Text without widow control, for a paragraph that holds a
# footnote (typst moves the line with the reference to the next page with its note, even when that leaves a widow).
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$OUT" \
  font="Times New Roman" size=28 body=628 single=400 indent=720 quote=280 note_after=140 > /dev/null
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
(cd "$T" && unzip -q "$OUT")
perl -0pi -e 's{(<w:style [^>]*w:styleId="BlockText")}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextNoted"><w:name w:val="Body Text Noted"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style>$1}s or die "BodyTextNoted"' "$T/word/styles.xml"
xmllint --noout "$T/word/styles.xml"
rm -f "$OUT"
(cd "$T" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
