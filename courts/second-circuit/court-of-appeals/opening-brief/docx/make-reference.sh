#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt (CA2-FORM-004; the typst template's font); Body Text and List
# Item in 31.4 pt line boxes (typst pitch-double, CA2-CONV-001) with a half-inch indent; quotations, footnotes and the
# heading styles in 20 pt boxes (typst pitch-single), quotations 14 pt above and below, 7 pt after each footnote
# (ca2.lua sets every heading's own spacing; the styles give the outline levels). Page setup and footers come from
# ca2.lua's sections and fb render. Usage: sh docx/make-reference.sh [out.docx]
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=628 single=400 indent=720 quote=280 note_after=140
