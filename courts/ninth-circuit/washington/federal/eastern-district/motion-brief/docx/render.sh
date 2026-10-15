#!/bin/sh
# DOCX engine for the E.D. Wash. motion with memorandum: sh docx/render.sh <court-dir> <sample.md, relative to the court
# dir> <out.docx>. Called by tools/render-docx.sh. Steps:
#  1. the footer title (the sample's footer_title, in capitals as the typst footer prints it) goes into a copy of
#     reference.docx;
#  2. pass 1: pandoc with motion-brief.lua writes the headings it found (MOTION_INDEX_OUT); the file is converted to PDF
#     and each heading's page is found in the page text (toc-pagemap.awk);
#  3. pass 2: pandoc again with the page numbers (MOTION_PAGES); the second pass must paginate like the first.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
# 1. footer title from the frontmatter
awk 'NR == 1 && /^---[ \t]*$/ { f = 1; next } f && /^---[ \t]*$/ { exit } f' "$COURT/$SAMPLE" > "$W/meta.yaml"
TITLE=$(yq -r '.footer_title // ""' "$W/meta.yaml" | tr 'a-z' 'A-Z' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
[ -n "$TITLE" ] || { echo "render.sh: sample has no footer_title" >&2; exit 1; }
mkdir "$W/ref" && (cd "$W/ref" && unzip -q "$D/reference.docx")
sed -i "s|@FOOTER_TITLE@|$TITLE|" "$W/ref/word/footer1.xml"
(cd "$W/ref" && zip -q -X "$W/ref.docx" '[Content_Types].xml' && zip -q -X -r "$W/ref.docx" _rels docProps word)
# 2. pass 1: the index of headings, then their pages in a PDF of pass 1
(cd "$COURT" && MOTION_INDEX_OUT="$W/index.tsv" pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" --lua-filter="$D/motion-brief.lua" "$SAMPLE" -o "$W/pass1.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile1" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice1.log" 2>&1 || { cat "$W/soffice1.log" >&2; exit 1; }
NP=$(pdfinfo "$W/pass1.pdf" | sed -n 's/^Pages: *//p')
p=1
while [ "$p" -le "$NP" ]; do
  pdftotext -x 75 -y 0 -W 465 -H 792 -f "$p" -l "$p" "$W/pass1.pdf" - | tr -d ' \t\r\n\f' > "$W/page.$p"
  p=$((p + 1))
done
gawk -v np="$NP" -v wd="$W" -F '\t' -f "$D/toc-pagemap.awk" "$W/index.tsv" > "$W/pages.tsv" || { echo "render.sh: page map failed" >&2; exit 1; }
# 3. pass 2 with the page numbers; the page count must not change
(cd "$COURT" && MOTION_PAGES="$W/pages.tsv" pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" --lua-filter="$D/motion-brief.lua" "$SAMPLE" -o "$W/pass2.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile2" --headless --convert-to pdf --outdir "$W" "$W/pass2.docx" > "$W/soffice2.log" 2>&1 || { cat "$W/soffice2.log" >&2; exit 1; }
NP2=$(pdfinfo "$W/pass2.pdf" | sed -n 's/^Pages: *//p')
[ "$NP2" = "$NP" ] || { echo "render.sh: second pass has $NP2 pages, first pass $NP: page map is stale" >&2; exit 1; }
mv "$W/pass2.docx" "$OUT"
echo "$OUT"
