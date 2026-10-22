#!/usr/bin/env bash
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"): TeX Gyre Schola 12 pt (Rule 33.1(b);
# the face the typst template sets) in 14 pt line boxes (12-point type, 2-point leading); Body Text with a 0.4 in
# indent and 12 pt (one em) after each paragraph (typst: par spacing), First Paragraph (after a heading) without the
# indent; block quotations 12 pt above and below; footnotes 10 pt in 12 pt boxes, 6 pt apart (typst footnote.entry).
# The page (booklet, Rule 33.1(a), (c)), the sections and the footers come from docx/brief.lua and fb render; the
# cover, headings, tables, signature and certificate are written by brief.lua with their own spacing.
# Usage: bash docx/build-reference.sh   (writes docx/reference.docx; needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")"; pwd)
OUT=$D/reference.docx
W=$(mktemp -d) || exit 1
safe_rmdir() { rm -r -- "${1:?}"; }
trap 'safe_rmdir "$W"' EXIT
sh "$D/../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" \
  font="TeX Gyre Schola" size=24 body=280 single=280 indent=576 quote=240 note=240 note_size=20 note_after=120 >/dev/null
mkdir "$W/pkg"
unzip -q "$W/ref.docx" -d "$W/pkg"
perl -0pi -e '
  s{(<w:style [^>]*w:styleId="BodyText".*?)<w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/>}{$1<w:spacing w:before="0" w:after="240" w:line="280" w:lineRule="exact"/>}s or die "BodyText";
  s{<w:styles }{<w:styles xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" mc:Ignorable="w14" }s or die "ns";
  s{(<w:rPrDefault>\s*<w:rPr>.*?)(</w:rPr>)}{$1<w14:ligatures w14:val="none"/>$2}s or die "ligatures";
  s{(<w:style [^>]*w:styleId="FirstParagraph".*?<w:qFormat/>)}{$1<w:pPr><w:ind w:firstLine="0"/></w:pPr>}s or die "FirstParagraph";
' "$W/pkg/word/styles.xml"
xmllint --noout "$W/pkg/word/styles.xml"
rm -f "$OUT"
(cd "$W/pkg"; zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
