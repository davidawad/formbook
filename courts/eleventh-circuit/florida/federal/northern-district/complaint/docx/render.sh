#!/bin/sh
# Renders the sample to .docx (docs/EVAL-LOOP.md, "Engines": docx/render.sh <court-dir> <sample.md> <out.docx>).
# The markdown is read as CommonMark with smart punctuation and a YAML block: the reading typst's cmarker gives.
# So "at *7" (a Westlaw star page) keeps its literal asterisk, and "No. 1" takes no no-break space. pandoc's own
# markdown reader does neither (docs/DOCX.md, "Known limits"). Styles and filters: reference.docx and the *.lua here.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086 # filters is a list of pandoc options, split on purpose
(cd "$COURT" && pandoc --from commonmark+smart+yaml_metadata_block --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$OUT")
