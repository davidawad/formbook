#!/bin/sh
# docx engine for msnb adversary complaints: sh docx/render.sh <court-dir> <sample.md> <out.docx>
# Called by tools/render-docx.sh. Pandoc runs with reference.docx and the Lua filter in this folder. Pandoc
# would read a "[^n]:" chunk as a link definition and drop it, so the brackets are escaped first.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
FILTERS=""
for f in "$D"/*.lua; do FILTERS="$FILTERS --lua-filter=$f"; done
# shellcheck disable=SC2086
cd "$COURT" && sed -E 's/^\[\^([0-9]+)\]:/\\[^\1]:/' "$2" | pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS -o "$OUT"
