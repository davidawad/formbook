#!/bin/sh
# DOCX engine for the E.D. Wash. complaint: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# The footer title (the sample's footer_title, in capitals as the typst footer prints it) goes into footer1.xml of a
# copy of reference.docx; then pandoc writes the body with complaint.lua. Called by tools/render-docx.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
# 1. footer title from the frontmatter (capitals, XML-escaped) into a copy of the reference
awk 'NR == 1 && /^---[ \t]*$/ { f = 1; next } f && /^---[ \t]*$/ { exit } f' "$COURT/$SAMPLE" > "$W/meta.yaml"
TITLE=$(yq -r '.footer_title // ""' "$W/meta.yaml" | tr 'a-z' 'A-Z' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
mkdir "$W/ref" && (cd "$W/ref" && unzip -q "$D/reference.docx")
if [ -n "$TITLE" ]; then
  sed -i "s|@FOOTER_TITLE@|$TITLE|" "$W/ref/word/footer1.xml"
else
  echo "render.sh: sample has no footer_title" >&2
  exit 1
fi
(cd "$W/ref" && zip -q -X "$W/ref.docx" '[Content_Types].xml' && zip -q -X -r "$W/ref.docx" _rels docProps word)
# 2. the body: pandoc with the reference and complaint.lua
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" --lua-filter="$D/complaint.lua" "$SAMPLE" -o "$OUT")
echo "$OUT"
