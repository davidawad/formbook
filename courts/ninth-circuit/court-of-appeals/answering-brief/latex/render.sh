#!/bin/sh
# Builds one sample with the ca9 LaTeX template (docs/EVAL-LOOP.md, "Engines"). Owns the whole build:
# pandoc writes doc.tex from template.tex and the Lua filter ca9.lua, then tectonic compiles it twice. The first
# pass writes the aux and toc files; the second reads them, so the table of contents and the table of authorities
# carry the page numbers of the final layout (LaTeX does not rerun for a changed toc file by itself).
# Usage: sh latex/render.sh <court-dir> <sample.md, relative to the court dir> <out.pdf>
set -eu
ROOT=$(cd "$(dirname "$0")/../../../../.." && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
L="$COURT/latex"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to latex --standalone --template="$L/template.tex" \
  -V "fontdir=$ROOT/fonts/" --lua-filter="$L/ca9.lua" "$SAMPLE" -o "$WORK/doc.tex") || exit 1
for pass in 1 2; do
  (cd "$WORK" && tectonic -X compile --keep-logs doc.tex > "build$pass.log" 2>&1) || {
    cat "$WORK/build$pass.log" >&2
    exit 1
  }
done
cp "$WORK/doc.pdf" "$OUT"
