#!/bin/sh
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 12 pt; Body Text (and First Paragraph) double-spaced in 24 pt
# exact line boxes with a half-inch first-line indent (37 CFR 2.126(a)(1); typst pitch-double); block quotations
# single-spaced (13.8 pt, typst pitch-single), a half inch in on both sides, 14 pt above and below; footnotes at the
# body size, single-spaced, 7 pt apart; US Letter, 1 in margins, a centered page number in the footer, the final
# section (the body) from 1. ttab-trial-brief.lua writes the caption page, the table of authorities, the headings,
# the signature block and the certificate with the typst template's pitches and spaces (twips = 20 x pt), and the
# front matter's roman sections.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$T/ref.docx" font="Times New Roman" size=24 body=480 \
  single=276 indent=720 quote=280 note_after=140 >/dev/null
mkdir "$T/w"
(cd "$T/w" && unzip -q "$T/ref.docx")
# the body's section numbers its pages from 1 (the front matter's sections are roman, written by the filter)
perl -0pi -e 's{(<w:pgMar [^>]*/>)}{$1<w:pgNumType w:fmt="decimal" w:start="1" />}s or die "pgMar"' "$T/w/word/document.xml"
xmllint --noout "$T/w/word/document.xml"
rm -f "$OUT"
(cd "$T/w" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
