#!/bin/sh
# docx engine for this doc type: tools/render-docx.sh hands the build to this file when it exists (docs/DOCX.md).
# pandoc with this folder's reference.docx and filter. Two things are done before pandoc reads the sample:
#   * a designation line in the frontmatter ("> Debtor.", indented in the caption) gets the word INDENTMARK in place of
#     its ">", because pandoc's YAML reader drops the ">" and the filter could not tell the line apart;
#   * fancy list markers are off, so "(A)" inside a block quotation stays text, as typst prints it.
# The sample itself is not changed. Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
cd "$COURT"
awk 'BEGIN { d = 0 }
  /^---[ \t]*$/ && d < 2 { d++; print; next }
  d == 1 && /^[ \t]*-[ \t]*"> / { sub(/"> /, "\"INDENTMARK ") }
  { print }' "$SAMPLE" > "$T/sample.md"
pandoc --from markdown+smart-fancy_lists --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/mnb-motion-brief.lua" "$T/sample.md" -o "$OUT"
