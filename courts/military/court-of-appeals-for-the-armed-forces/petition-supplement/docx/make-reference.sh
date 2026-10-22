#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt (the typst face; Rule 37(a): 14-point type, footnotes
# included); Body Text in 25.9 pt line boxes (typst pitch-double) with a half-inch first-line indent; quotations and
# footnotes in 14.4 pt boxes (typst pitch-single), 14 pt around a quotation, 7 pt after a footnote. armfor.lua sets
# every other paragraph's own spacing. Usage: sh docx/make-reference.sh [out.docx]
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=518 single=288 indent=720 quote=280 note_after=140 footer=718
