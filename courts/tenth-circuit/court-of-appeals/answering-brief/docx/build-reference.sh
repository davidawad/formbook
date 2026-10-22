#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt everywhere, footnotes too (CA10-FORM-004, 10th Cir. R.
# 32(A)); Body Text and List Item in 28.1 pt line boxes (typst pitch-double, CA10-FORM-003) with a half-inch indent;
# quotations, footnotes and the heading styles in 18.8 pt boxes (typst pitch-single); quotations 14 pt above and
# below, footnotes 7 pt apart (typst quote, footnote.entry). ca10.lua writes every heading, the cover, the tables and
# the certificates with their own spacing; the styles give the body text and the outline levels.
# Usage: sh docx/build-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=562 single=376 indent=720 heading=376 quote=280 note_after=140
