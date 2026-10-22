#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt everywhere, footnotes too (FRAP 32(a)(5)(A), 10th Cir.
# R. 32(A)); Body Text and List Item in 31.4 pt line boxes (typst pitch-double, FRAP 32(a)(4)) with a half-inch
# indent; quotations, footnotes and the heading styles in 20 pt boxes (typst pitch-single); quotations 14 pt above
# and below, footnotes 7 pt apart (typst quote, footnote.entry). ca10.lua writes every heading, the cover, the tables
# and the certificates with their own spacing; the styles give the body text and the outline levels.
# One style of its own: "Body Text Note", Body Text without widow control, for a paragraph that carries a footnote
# mark. typst keeps a paragraph's first (last) two lines together by their height alone; when the second line's
# footnote does not fit, that line moves on and the first stays behind alone. Word's widow control would move both
# (and the heading before them): with it off, Word leaves the line where typst does.
# Usage: sh docx/build-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" \
  font="Times New Roman" size=28 body=628 single=400 indent=720 heading=400 quote=280 note_after=140 >/dev/null
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q ../ref.docx)
perl -0pi -e 's{(</w:styles>)}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextNote"><w:name w:val="Body Text Note"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style>$1}s or die "styles"' "$W/pkg/word/styles.xml"
xmllint --noout "$W/pkg/word/styles.xml"
rm -f "$OUT"
(cd "$W/pkg" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
