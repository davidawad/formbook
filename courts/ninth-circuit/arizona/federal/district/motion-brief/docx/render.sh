#!/bin/sh
# DOCX engine for the azd motion with memorandum (docs/DOCX.md). Called by tools/render-docx.sh as
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# 1. pandoc: the markdown -> a .docx on docx/reference.docx, with every docx/*.lua filter (azd-motion.lua);
# 2. the running header (pages 2 on: case number, short title, judge) is case-specific, so it is taken from the
#    sample's frontmatter (running_header) and written into the placeholder <!--RUNNING--> of the default header;
# 3. the package is re-zipped with [Content_Types].xml first.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$W/body.docx")

mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/body.docx"
HDR=$(grep -l 'RUNNING' word/*.xml 2> /dev/null | head -1 || true)
if [ -z "$HDR" ]; then
  echo "motion render.sh: the running-header placeholder is missing from the pandoc output" >&2
  exit 1
fi
yq --front-matter=extract '.running_header[]' "$COURT/$SAMPLE" > "$W/running.txt"
[ -s "$W/running.txt" ] || {
  echo "motion render.sh: the sample has no running_header frontmatter" >&2
  exit 1
}
{
  while IFS= read -r line; do
    esc=$(printf '%s' "$line" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
    printf '<w:p><w:pPr><w:pStyle w:val="RunningHeader"/></w:pPr><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p>\n' "$esc"
  done < "$W/running.txt"
} > "$W/running.xml"
awk -v f="$W/running.xml" '/<!--RUNNING-->/ { while ((getline l < f) > 0) print l; next } { print }' "$HDR" > "$W/hdr.xml"
mv "$W/hdr.xml" "$HDR"
xmllint --noout "$HDR"

rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find . -type f | sed 's|^\./||' | grep -v '^\[Content_Types\]\.xml$' | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
