#!/usr/bin/env bash
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Liberation Serif 14 pt (FRBP 8015(a)(5)(A); the face the typst template sets);
# Body Text and List Item in 31.4 pt line boxes (typst pitch-double, FRBP 8015(a)(4): double-spaced) with a
# half-inch indent; quotations (14 pt above and below) and footnotes (14 pt, L.R. 8015-1(b); 7 pt after each) in
# 20 pt boxes (typst pitch-single); the heading styles give the outline levels (bap10.lua sets every heading's own
# spacing, size and pitch). Page setup, sections and footers come from bap10.lua and fb render, not from here.
# Usage: bash docx/build-reference.sh   (writes docx/reference.docx; needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")"; pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "$D/reference.docx" \
  font="Liberation Serif" size=28 body=628 single=400 indent=720 quote=280 note=400 note_size=28 note_after=140
