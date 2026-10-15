#!/bin/sh
# docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Builds the .docx for one sample (the contract of tools/render-docx.sh). Steps:
#  1. the cover footer gets the oral-argument legend from the sample's frontmatter (oral_argument), or none;
#  2. pandoc with reference.docx and motion-brief.lua; the first pass also writes the search index (MOTION_INDEX_OUT);
#  3. the first pass is converted to PDF with soffice, the page text is read, and pagemap.awk finds the printed page of
#     every heading and every authority; pandoc runs again with that page map (MOTION_PAGES), and the second pass must
#     paginate exactly like the first (else the map is stale and the build fails).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FILTERS=""
for f in "$D"/*.lua; do [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"; done

# 1. the cover legend: "Oral argument <value>" in capitals (typst/ctd-motion-brief.typ), empty when the sample has none
awk 'NR == 1 && /^---[ \t]*$/ { f = 1; next } f && /^---[ \t]*$/ { exit } f' "$COURT/$SAMPLE" > "$W/meta.yaml"
LEGEND=$(yq -r '.oral_argument // ""' "$W/meta.yaml")
if [ -n "$LEGEND" ]; then
  LEGEND=$(printf 'ORAL ARGUMENT %s' "$LEGEND" | tr 'a-z' 'A-Z' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
fi
mkdir "$W/ref" && (cd "$W/ref" && unzip -q "$D/reference.docx")
sed -i "s|@COVER_LEGEND@|$LEGEND|" "$W/ref/word/footer2.xml"
(cd "$W/ref" && zip -q -X "$W/ref.docx" '[Content_Types].xml' && zip -q -X -r "$W/ref.docx" _rels docProps word)

# 2. pandoc pass (the first pass also writes the search index)
export MOTION_INDEX_OUT="$W/index.tsv"
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" $FILTERS "$SAMPLE" -o "$W/pass1.docx") || exit 1
unset MOTION_INDEX_OUT

# 3. page map from the first pass
"$SOFFICE" "-env:UserInstallation=file://$W/profile1" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice1.log" 2>&1 || { cat "$W/soffice1.log" >&2; exit 1; }
NP=$(pdfinfo "$W/pass1.pdf" | sed -n 's/^Pages: *//p')
p=1
while [ "$p" -le "$NP" ]; do
  pdftotext -f "$p" -l "$p" "$W/pass1.pdf" - | tr -d ' \t\r\n\f' | tr 'A-Z' 'a-z' > "$W/page.$p"
  p=$((p + 1))
done
gawk -v np="$NP" -v wd="$W" -F '\t' -f "$D/pagemap.awk" "$W/index.tsv" > "$W/pages.tsv" || { echo "render.sh: page map failed" >&2; exit 1; }
export MOTION_PAGES="$W/pages.tsv"
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" $FILTERS "$SAMPLE" -o "$W/pass2.docx") || exit 1
unset MOTION_PAGES

# the page numbers in the map are only right if the second pass paginates like the first
"$SOFFICE" "-env:UserInstallation=file://$W/profile2" --headless --convert-to pdf --outdir "$W" "$W/pass2.docx" > "$W/soffice2.log" 2>&1 || { cat "$W/soffice2.log" >&2; exit 1; }
NP2=$(pdfinfo "$W/pass2.pdf" | sed -n 's/^Pages: *//p')
[ "$NP2" = "$NP" ] || { echo "render.sh: second pass has $NP2 pages, first pass $NP: page map is stale" >&2; exit 1; }
mv "$W/pass2.docx" "$OUT"
echo "$OUT"
