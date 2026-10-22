#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"), to the form of typst/bap9-*.typ:
# Times New Roman 14 pt (BAP-FORM-002); Body Text and List Item in 31 pt line boxes (typst pitch-double, BAP-FORM-003)
# with a half-inch indent; quotations and footnotes (14 pt, 7 pt apart) in 17 pt boxes (typst pitch-single), a
# quotation 12 pt above and below. docx/bap9.lua writes the cover, tables, headings, signature and certificates
# with their own spacing; fb render writes the footers and sections.
# Usage: sh docx/build-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "${1:-$D/reference.docx}" \
  font="Times New Roman" size=28 body=620 single=340 indent=720 heading=340 quote=240 note_after=140
