#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt (FRAP 32(a)(5), Handbook IX.A.6; the typst template's font);
# Body Text and List Item in 29.4 pt line boxes (typst pitch-double, FRAP 32(a)(4)) with a half-inch indent;
# quotations, footnotes and the heading styles in 17 pt boxes (typst pitch-single), quotations 14 pt above and below,
# 7 pt after each footnote (cadc.lua sets every heading's and quotation paragraph's own spacing; the styles give the
# outline levels). Page setup and footers come from cadc.lua's sections and fb render.
# Usage: sh docx/make-reference.sh [out.docx]
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=588 single=340 indent=720 quote=280 note_after=140
