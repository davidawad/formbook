#!/bin/sh
# Rebuild docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 12 pt; Body Text (and First Paragraph) double-spaced in 27.6 pt
# exact line boxes with a 0.5 in first-line indent (37 CFR 2.126(a)(1); typst pitch-double); List Item with the
# bullet in a half-inch box; single-spaced lines 13.8 pt (typst pitch-single); Letter, 1 in margins, a centred
# page-number footer. docx/ttab-answer.lua writes the caption, headings, quotations, signature block and
# certificate as paragraphs with their own exact spacing (the typst template's pitches and spaces, twips = 20 x pt).
# Usage: sh docx/make-reference.sh   (run from anywhere; needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$D/reference.docx" font="Times New Roman" size=24 body=552 \
  single=276 indent=720 list=720
