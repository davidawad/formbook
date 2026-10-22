#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 12 pt, the typst face (Rule 17.1(a)); Body Text in 24.6 pt line
# boxes (typst pitch-body, double-spaced) with a half-inch first-line indent; block quotations, footnotes and the
# heading styles in 14.7 pt boxes (typst pitch-single); 12 pt above and below a quotation, 6 pt after a footnote
# (typst quote block and footnote.entry gap). afcca.lua writes every other paragraph with its own spacing.
# Usage: sh docx/make-reference.sh [out.docx]
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=24 body=492 single=294 indent=720 heading=294 quote=240 note_after=120
