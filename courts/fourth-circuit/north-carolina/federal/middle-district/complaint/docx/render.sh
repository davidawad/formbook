#!/bin/sh
# docx engine for the complaint: sh docx/render.sh <court-dir> <sample.md> <out.docx>
# The samples put a footnote definition on the line after its paragraph (the contract in ../README.md); pandoc
# needs a blank line before a definition, so a temporary copy gets one. The sample itself is not changed.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
awk '/^\[\^[^]]+\]:/ && prev != "" { print "" } { print; prev = $0 }' "$COURT/$SAMPLE" > "$T/in.md"
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$T/in.md" -o "$OUT")
