#!/usr/bin/env bash
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): TeX Gyre Schola 14 pt (FRAP 32(a)(5); the typst template's font); Body Text and List
# Item in 26.4 pt line boxes (typst pitch-double, FRAP 32(a)(4)) with a half-inch indent; quotations, footnotes and the
# heading styles in 17.5 pt boxes (typst pitch-single), quotations 14 pt above and below, 7 pt after each footnote
# (cadc.lua sets every heading's own spacing; the styles give the outline levels). Page setup and footers come from
# cadc.lua's sections and fb render. Usage: bash docx/make-reference.sh
set -euo pipefail
D=$(dirname "$0")
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "$D/reference.docx" \
  font="TeX Gyre Schola" size=28 body=528 single=350 indent=720 quote=280 note_after=140
