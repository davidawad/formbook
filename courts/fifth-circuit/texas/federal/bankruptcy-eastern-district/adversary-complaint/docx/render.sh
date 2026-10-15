#!/bin/sh
# DOCX engine for the adversary complaint (docs/DOCX.md). tools/render-docx.sh calls this as
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc reads the sample with the txeb Lua filter and reference.docx. The footer of reference.docx is then completed
# from the sample's footer_title (in capitals), as the typst template prints it. Then the .docx is written to <out.docx>.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
# -tex_math_dollars: "$" is a dollar amount; -definition_lists: "~" opens a paragraph, not a definition; -fancy_lists: "(c)" and "(1)" open a paragraph, not a list
(cd "$COURT" && pandoc --from=markdown-tex_math_dollars-definition_lists-fancy_lists-raw_html+smart --to=docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/txeb-adversary-complaint.lua" \
  "$SAMPLE" -o "$T/out.docx")
TITLE=$(awk -F': *' '/^footer_title:/ { v = $2; gsub(/"/, "", v); print toupper(v); exit }' "$COURT/$SAMPLE")
[ -n "$TITLE" ] || {
  echo "render.sh: the sample has no footer_title" >&2
  exit 1
}
TITLE=$(printf '%s' "$TITLE" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
mkdir "$T/pkg"
(cd "$T/pkg" && unzip -q "$T/out.docx")
HITS=$(grep -l '@FOOTER_TITLE@' -r "$T/pkg/word" || true)
[ -n "$HITS" ] || {
  echo "render.sh: no footer carries the title placeholder" >&2
  exit 1
}
for f in $HITS; do sed -i "s|@FOOTER_TITLE@|$TITLE|" "$f"; done
rm -f "$OUT"
(cd "$T/pkg" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
