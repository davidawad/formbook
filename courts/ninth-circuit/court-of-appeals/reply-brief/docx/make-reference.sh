#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt (CA9-FORM-004); Body Text and List Item in 29.4 pt line
# boxes (typst pitch-double, CA9-FORM-003) with a half-inch indent; quotations and footnotes in 17 pt boxes (typst
# pitch-single); the heading styles in 19.95 pt boxes (ca9.lua sets every heading's own spacing; the styles give
# the outline levels). Usage: sh docx/make-reference.sh [out.docx]
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=588 single=340 indent=720 heading=399
