#!/usr/bin/env bash
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): TeX Gyre Termes 12 pt (the typst face); Body Text (and First Paragraph) double-spaced in 24 pt
# exact line boxes with a half-inch first-line indent (37 CFR 2.126(a)(1); typst pitch-double); single-spaced
# lines 13.8 pt (typst pitch-single); US Letter, 1 in margins, a centered page number in the footer.
# docx/ttab-notice.lua writes the front matter, the count headings, the signature block and the slip sheets as
# paragraphs with their own exact spacing (the typst template's pitches and spaces, twips = 20 x pt).
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$OUT" font="TeX Gyre Termes" size=24 body=480 single=276 \
  indent=720
