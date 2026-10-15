#!/bin/sh
# DOCX engine for the D. Or. adversary complaint: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc writes the body on reference.docx with orb-complaint.lua; then the sample's footer_title (frontmatter) goes
# into the footer's title line, in capitals as the typst footer sets it. Called by tools/render-docx.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
pandoc --from markdown+smart-definition_lists --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/orb-complaint.lua" "$SAMPLE" -o "$W/raw.docx"
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/raw.docx"
TITLE=$(yq --front-matter=extract '.footer_title // ""' "$COURT/$SAMPLE")
TITLE=$(printf '%s' "$TITLE" | tr 'a-z' 'A-Z' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
sed -i "s|@FOOTER_TITLE@|$TITLE|" word/footer1.xml
xmllint --noout word/footer1.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
