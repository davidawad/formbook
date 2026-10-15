#!/bin/sh
# Writes the .docx for the motion-brief sample (docs/DOCX.md; render-docx.sh hands the build to this script when
# it exists): sh docx/render.sh <court-dir> <sample.md> <out.docx>.
# Westlaw star paging ("at *8", "at * 3") is escaped before pandoc reads the sample: pandoc takes a pair of those
# asterisks for italic markup and drops them, where the typst template prints them as written. Real emphasis
# (*Id.*, *see generally*) is left alone: only an asterisk followed by a digit (or a space and a digit) is escaped.
# The Lua filter and reference.docx come from this folder, as in render-docx.sh.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sed -e 's/\*\( \{0,1\}[0-9]\)/\\*\1/g' "$COURT/$SAMPLE" > "$W/sample.md"
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$W/sample.md" -o "$OUT"
