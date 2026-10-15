#!/bin/sh
# DOCX build for the D. Alaska memorandum (akd), engine docx (docs/DOCX.md). Owns the .docx:
#   sh docx/render.sh <doc-dir> <sample.md, relative to the doc dir> <out.docx>
# 1. pandoc (markdown -> docx) on docx/reference.docx with docx/akd-motion-brief.lua (cover, contents, authorities,
#    section break, numbering, signature, certificate);
# 2. the contents and authorities need page numbers, which Word fields would leave empty in LibreOffice. So the
#    build runs in passes: each pass is converted to PDF with LibreOffice, docx/find-pages.awk finds the printed
#    page of every heading and citation (a needle search on the text), and the next pass writes those numbers.
#    The passes repeat until the numbers do not change (at most 4 passes; then this fails);
# 3. the footer's text lines are set from the frontmatter (footer_title; case_name and case_number), the
#    placeholders @FOOTER_TITLE@ and @FOOTER_CASE@ in word/footer1.xml;
# 4. the package is rewritten as a zip and every XML part is checked.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
cd "$COURT"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

awk 'BEGIN { n = 0 } /^---[ \t]*$/ && n < 2 { n++; next } n == 1' "$SAMPLE" > "$W/fm.yaml"
FOOTER_TITLE=$(yq e '.footer_title' "$W/fm.yaml")
CASE_NAME=$(yq e '.case_name' "$W/fm.yaml")
CASE_NO=$(yq e '.case_number' "$W/fm.yaml")
for v in "$FOOTER_TITLE" "$CASE_NAME" "$CASE_NO"; do
  [ -n "$v" ] && [ "$v" != null ] || { echo "render.sh: the sample needs footer_title, case_name and case_number" >&2; exit 1; }
done
xesc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
FT=$(xesc "$FOOTER_TITLE")
FC=$(xesc "$CASE_NAME, Case No. $CASE_NO")

# one build: $1 = page-label file ("" for none), $2 = the .docx to write
build() {
  rm -rf "$W/pkg"
  AKD_PAGES="$1" AKD_EMIT="$W/needles.tsv" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/akd-motion-brief.lua" "$SAMPLE" -o "$W/stage.docx"
  mkdir "$W/pkg" && (cd "$W/pkg" && unzip -q "$W/stage.docx")
  for f in "$W/pkg"/word/footer*.xml; do
    [ -f "$f" ] || continue
    sed -i -e "s|@FOOTER_TITLE@|$FT|" -e "s|@FOOTER_CASE@|$FC|" "$f"
    grep -q '@FOOTER' "$f" && { echo "render.sh: $f keeps a placeholder" >&2; exit 1; }
    xmllint --noout "$f"
  done
  for part in word/document.xml word/styles.xml; do xmllint --noout "$W/pkg/$part"; done
  rm -f "$2"
  (cd "$W/pkg" && ziptool -n "$2" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null \
    && find . -type f ! -name '[[]Content_Types[]].xml' | sed 's|^\./||' | sort | while IFS= read -r f; do
      ziptool "$2" add_file "$f" "$f" 0 0 > /dev/null
    done)
  unzip -tq "$2" > /dev/null
}

# the page labels of the events from a converted copy of one build
labels() {
  rm -rf "$W/conv" && mkdir "$W/conv"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W/conv" "$1" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    exit 1
  }
  printf "%s\n%s\n" "$FOOTER_TITLE" "$CASE_NAME, Case No. $CASE_NO" > "$W/footers.txt"
  pdftotext -enc UTF-8 "$W/conv/$(basename "${1%.docx}").pdf" - | LC_ALL=C awk -v NEEDLES="$W/needles.tsv" -v FOOTERS="$W/footers.txt" -f "$D/find-pages.awk" > "$W/labels.tsv" || exit 1
}

PASS=0
: > "$W/pages.tsv"
build "" "$W/pass0.docx"
labels "$W/pass0.docx"
cp "$W/labels.tsv" "$W/pages.tsv"
while :; do
  PASS=$((PASS + 1))
  [ "$PASS" -le 4 ] || { echo "render.sh: the page numbers did not settle in 4 passes" >&2; exit 1; }
  build "$W/pages.tsv" "$W/pass$PASS.docx"
  labels "$W/pass$PASS.docx"
  if cmp -s "$W/labels.tsv" "$W/pages.tsv"; then break; fi
  cp "$W/labels.tsv" "$W/pages.tsv"
done
grep -q '??' "$W/pages.tsv" && { echo "render.sh: a heading or citation was not found in the rendered text:" >&2; grep '??' "$W/pages.tsv" >&2; exit 1; }
cp "$W/pass$PASS.docx" "$OUT"
echo "$OUT"
