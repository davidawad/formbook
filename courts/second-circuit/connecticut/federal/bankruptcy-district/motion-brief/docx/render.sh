#!/bin/sh
# DOCX engine for the D. Conn. memorandum in support of a motion: sh docx/render.sh <court-dir> <sample.md, relative to the
# court dir> <out.docx>. Called by tools/render-docx.sh. Steps:
#  1. the docket line (adv_number, judge) and the cover's oral-argument legend come from the sample's frontmatter and go into
#     a copy of reference.docx (placeholders {{ADV_NUMBER}}, {{JUDGE}}, {{ORAL_ARGUMENT}}); the reference stays generic;
#  2. pass 1 (pandoc, ctb-motion-brief.lua) writes the search index; soffice makes its PDF; the page of each heading is found in
#     the PDF text (pagemap.awk), counted from the body's first page;
#  3. pass 2 writes the table of contents with those pages; its PDF must have the same page count and the same map.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
awk 'NR == 1 && /^---[ \t]*$/ { f = 1; next } f && /^---[ \t]*$/ { exit } f' "$COURT/$SAMPLE" > "$W/meta.yaml"
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
ADV=$(esc "$(yq -r '.adv_number' "$W/meta.yaml")")
JUDGE=$(esc "$(yq -r '.judge' "$W/meta.yaml")")
OA=$(yq -r '.oral_argument // ""' "$W/meta.yaml")
case $OA in
  requested) ORAL="ORAL ARGUMENT REQUESTED" ;;
  "") ORAL="" ;;
  *) ORAL="ORAL ARGUMENT NOT REQUESTED" ;;
esac
mkdir "$W/ref" && (cd "$W/ref" && unzip -q "$D/reference.docx")
sed -i -e "s|{{ADV_NUMBER}}|$ADV|" -e "s|{{JUDGE}}|$JUDGE|" "$W/ref/word/header1.xml"
sed -i -e "s|{{ORAL_ARGUMENT}}|$ORAL|" "$W/ref/word/footer2.xml"
(cd "$W/ref" && zip -q -X "$W/ref.docx" '[Content_Types].xml' && zip -q -X -r "$W/ref.docx" _rels docProps word)
FILTER="--lua-filter=$D/ctb-motion-brief.lua"

# 1. pass 1: the index, and the PDF of the pass
(cd "$COURT" && CTB_INDEX_OUT="$W/index.tsv" pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" $FILTER "$SAMPLE" -o "$W/pass1.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile1" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice1.log" 2>&1 || { cat "$W/soffice1.log" >&2; exit 1; }
NP=$(pdfinfo "$W/pass1.pdf" | sed -n 's/^Pages: *//p')
p=1
while [ "$p" -le "$NP" ]; do
  pdftotext -f "$p" -l "$p" "$W/pass1.pdf" - | tr -d ' \t\r\n\f' > "$W/page.$p"
  p=$((p + 1))
done

# 2. the page map, and pass 2 with it
gawk -v np="$NP" -v wd="$W" -f "$D/pagemap.awk" "$W/index.tsv" > "$W/pages.tsv" || { echo "render.sh: page map failed" >&2; exit 1; }
(cd "$COURT" && CTB_PAGES="$W/pages.tsv" pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" $FILTER "$SAMPLE" -o "$W/pass2.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile2" --headless --convert-to pdf --outdir "$W" "$W/pass2.docx" > "$W/soffice2.log" 2>&1 || { cat "$W/soffice2.log" >&2; exit 1; }
NP2=$(pdfinfo "$W/pass2.pdf" | sed -n 's/^Pages: *//p')
[ "$NP2" = "$NP" ] || { echo "render.sh: second pass has $NP2 pages, first pass $NP: page map is stale" >&2; exit 1; }
p=1
while [ "$p" -le "$NP2" ]; do
  pdftotext -f "$p" -l "$p" "$W/pass2.pdf" - | tr -d ' \t\r\n\f' > "$W/page.$p"
  p=$((p + 1))
done
gawk -v np="$NP2" -v wd="$W" -f "$D/pagemap.awk" "$W/index.tsv" > "$W/pages2.tsv" || { echo "render.sh: page map of pass 2 failed" >&2; exit 1; }
cmp -s "$W/pages.tsv" "$W/pages2.tsv" || { echo "render.sh: table of contents pages differ between passes" >&2; exit 1; }
rm -f "$OUT"
cp "$W/pass2.docx" "$OUT"
echo "$OUT"
