#!/bin/sh
# docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Builds the .docx for one sample (the contract of tools/render-docx.sh). Steps:
#  1. the footer text (title, case number) is read from the sample's frontmatter and written into a copy of
#     reference.docx (placeholders {{FOOTER_TITLE}} and {{CASE_NO}}); the reference itself stays generic;
#  2. pandoc with the reference and every docx/*.lua filter;
#  3. if the filters wrote a search index (NMID_INDEX_OUT; motion brief: TOC and TOA page numbers), a first pass is
#     converted to PDF with soffice, the pages are found in its text, and pandoc runs again with the page map.
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

# 1. footer text from the frontmatter
awk 'NR == 1 && /^---[ \t]*$/ { f = 1; next } f && /^---[ \t]*$/ { exit } f' "$COURT/$SAMPLE" > "$W/meta.yaml"
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
TITLE=$(esc "$(yq -r '.footer_title' "$W/meta.yaml")")
CASE=$(esc "$(yq -r '.case_number' "$W/meta.yaml")")
mkdir "$W/ref" && (cd "$W/ref" && unzip -q "$D/reference.docx")
sed -i -e "s|{{FOOTER_TITLE}}|$TITLE|" -e "s|{{CASE_NO}}|$CASE|" "$W/ref/word/footer1.xml"
(cd "$W/ref" && zip -q -X "$W/ref.docx" '[Content_Types].xml' && zip -q -X -r "$W/ref.docx" _rels docProps word)

# 2. pandoc pass (the first pass also writes the search index, if the filters ask for one)
export NMID_INDEX_OUT="$W/index.tsv"
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" $FILTERS "$SAMPLE" -o "$W/pass1.docx") || exit 1
unset NMID_INDEX_OUT

# 3. page map from a first pass (only when the filters asked for one)
if [ -s "$W/index.tsv" ]; then
  "$SOFFICE" "-env:UserInstallation=file://$W/profile1" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice1.log" 2>&1 || { cat "$W/soffice1.log" >&2; exit 1; }
  NP=$(pdfinfo "$W/pass1.pdf" | sed -n 's/^Pages: *//p')
  p=1
  while [ "$p" -le "$NP" ]; do
    pdftotext -x 60 -y 0 -W 552 -H 792 -f "$p" -l "$p" "$W/pass1.pdf" - | tr -d ' \t\r\n\f' > "$W/page.$p"
    p=$((p + 1))
  done
  gawk -v np="$NP" -v wd="$W" -F '\t' -f "$D/pagemap.awk" "$W/index.tsv" > "$W/pages.tsv" || { echo "render.sh: page map failed" >&2; exit 1; }
  export NMID_PAGES="$W/pages.tsv"
  (cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" $FILTERS "$SAMPLE" -o "$W/pass2.docx") || exit 1
  # the page numbers in the map are only right if the second pass paginates like the first
  "$SOFFICE" "-env:UserInstallation=file://$W/profile2" --headless --convert-to pdf --outdir "$W" "$W/pass2.docx" > "$W/soffice2.log" 2>&1 || { cat "$W/soffice2.log" >&2; exit 1; }
  NP2=$(pdfinfo "$W/pass2.pdf" | sed -n 's/^Pages: *//p')
  [ "$NP2" = "$NP" ] || { echo "render.sh: second pass has $NP2 pages, first pass $NP: page map is stale" >&2; exit 1; }
  mv "$W/pass2.docx" "$OUT"
else
  mv "$W/pass1.docx" "$OUT"
fi
echo "$OUT"
