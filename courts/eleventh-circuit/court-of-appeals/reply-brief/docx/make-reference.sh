#!/usr/bin/env bash
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 14 pt everywhere
# (CA11-FORM-003); Body Text and List Item in 31.4 pt line boxes (typst pitch-double, 11th Cir. R. 32-3) with a
# half-inch indent; block quotations (14 pt above and below) and footnotes (14 pt, 7 pt apart) in 20 pt boxes (typst
# pitch-single); letter page with 1-inch margins. The cover, headings, tables and certificates are written by
# docx/ca11.lua as paragraphs with their own spacing; the footers of the sections are added by docx/render.sh.
# Usage: bash docx/make-reference.sh   (writes docx/reference.docx; needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")"; pwd)
exec sh "$D/../../../../../lib/docx/xengine-reference.sh" "$D/reference.docx" \
  font="Times New Roman" size=28 body=628 single=400 indent=720 list=720 heading=400 quote=280 \
  note=400 note_size=28 note_after=140 footer=608
