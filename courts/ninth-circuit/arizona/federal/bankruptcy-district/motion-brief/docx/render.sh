#!/bin/sh
# DOCX engine for the motion with memorandum (arb). Called by tools/render-docx.sh with
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc on reference.docx with arb-motion.lua, then the footer tokens (the title, and CASE NO. or ADV. NO.)
# are filled from the sample's frontmatter.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
fm() { awk 'NR==1 && /^---[ \t]*$/ {f=1; next} f && /^---[ \t]*$/ {exit} f' "$COURT/$SAMPLE" | yq -r ".$1"; }
esc() { printf '%s' "$1" | sed 's/&/\&amp;/g'; }
TITLE=$(esc "$(fm footer_title | tr '[:lower:]' '[:upper:]')")
ADV=$(fm adversary_number)
if [ "$ADV" != null ] && [ -n "$ADV" ]; then
  RIGHT=$(esc "ADV. NO. $ADV")
else
  RIGHT=$(esc "CASE NO. $(fm debtor.case_number)")
fi
(cd "$COURT" && pandoc --from markdown+smart-fancy_lists --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/arb-motion.lua" "$SAMPLE" -o "$W/out.docx")
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/out.docx"
for f in word/footer*.xml; do
  [ -f "$f" ] || continue
  sed -i -e "s|@FOOTER_TITLE@|$TITLE|" -e "s|@FOOTER_RIGHT@|$RIGHT|" "$f"
done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
