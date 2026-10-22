#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt, the face the typst template names (FRAP 32(a)(5)(A));
# Body Text and List Item in 31.4 pt line boxes (typst pitch-double, FRAP 32(a)(4) double spacing) with a half-inch
# indent; quotations and footnotes (14 pt too) in 20 pt boxes (typst pitch-single), 14 pt around a quotation and 7 pt
# after a footnote; the heading styles in 20 pt boxes (ca1.lua sets every heading's own spacing; the styles give the
# outline levels). The page setup, sections and footers come from ca1.lua and fb render (docxpass.rs), not from here.
# Usage: sh docx/make-reference.sh [out.docx]    (run once; the output is committed. Same in every doc type.)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=628 single=400 indent=720 heading=400 quote=280 note_after=140
