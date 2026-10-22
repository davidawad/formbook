#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"): TeX Gyre Schola 12 pt (Rule 33.1(b);
# the face the typst template sets) in 14 pt line boxes (12-point type, 2-point leading); Body Text with a 0.5 in
# indent and 10.8 pt (0.9 em) after each paragraph (typst: par spacing), First Paragraph (after a heading) without the
# indent; block quotations 0.5 in in on both sides, 10.8 pt above and below; footnotes 10 pt in 12 pt boxes, 6 pt apart.
# Two styles of its own, "Body Text Note" and "First Paragraph Note": without widow control, for a paragraph with
# a footnote mark (typst keeps two lines together by their height alone; a line whose footnote does not fit moves on).
# The page (booklet, Rule 33.1(a), (c)), the sections and the footers come from docx/scotus.lua and fb render; the
# cover, headings, tables, signature and certificate are written by scotus.lua with their own spacing.
# Usage: sh docx/build-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" \
  font="TeX Gyre Schola" size=24 body=280 single=280 indent=720 quote=216 note=240 note_size=20 note_after=120 >/dev/null
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q ../ref.docx)
perl -0pi -e '
  s{(<w:style [^>]*w:styleId="BodyText".*?)<w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/>}{$1<w:spacing w:before="0" w:after="216" w:line="280" w:lineRule="exact"/>}s or die "BodyText";
  s{<w:styles }{<w:styles xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" mc:Ignorable="w14" }s or die "ns";
  s{(<w:rPrDefault>\s*<w:rPr>.*?)(</w:rPr>)}{$1<w14:ligatures w14:val="none"/>$2}s or die "ligatures";
  s{(<w:style [^>]*w:styleId="FirstParagraph".*?<w:qFormat/>)}{$1<w:pPr><w:ind w:firstLine="0"/></w:pPr>}s or die "FirstParagraph";
  s{(</w:styles>)}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextNote"><w:name w:val="Body Text Note"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraphNote"><w:name w:val="First Paragraph Note"/><w:basedOn w:val="FirstParagraph"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style>$1}s or die "Note styles";
' "$W/pkg/word/styles.xml"
xmllint --noout "$W/pkg/word/styles.xml"
rm -f "$OUT"
(cd "$W/pkg" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
