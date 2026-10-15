#!/bin/sh
# DOCX engine for the D. Or. motion with memorandum: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc writes the body on reference.docx with motion.lua; then the sample's footer_title (frontmatter), in capitals,
# goes into the footer (@FOOTER_TITLE@). Called by tools/render-docx.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/motion.lua" "$SAMPLE" -o "$W/raw.docx"
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/raw.docx"
TITLE=$(yq --front-matter=extract '.footer_title // ""' "$COURT/$SAMPLE")
TITLE=$(printf '%s' "$TITLE" | tr 'a-z' 'A-Z' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
[ -n "$TITLE" ] || { echo "render.sh: the sample has no footer_title" >&2; exit 1; }
sed -i "s|@FOOTER_TITLE@|$TITLE|" word/footer1.xml
xmllint --noout word/footer1.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
