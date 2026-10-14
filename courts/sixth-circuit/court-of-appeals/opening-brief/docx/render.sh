#!/bin/sh
# docx engine for the ca6 opening brief: writes the .docx for one sample (called by tools/render-docx.sh).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# The TOC and the TOA carry page numbers, which only the rendered PDF knows. Each pass builds the .docx, converts
# it with LibreOffice, reads the printed page of every TOC heading and every citation from the PDF text
# (docx/pages.lua), and builds again with those numbers. Page numbers in the front matter can change the
# front matter's length, but the body restarts on its own page, so the body's numbers settle in one pass; the
# loop stops when a pass reads the same numbers it was built with (at most four passes).
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice)}
REF=$D/reference.docx
if grep -q -i '^# *addendum *$' "$COURT/$SAMPLE"; then REF=$D/reference-addendum.docx; fi
[ -f "$REF" ] || {
  echo "docx/render.sh: $REF is missing; run docx/make-reference.sh" >&2
  exit 1
}
FILTERS=""
for f in "$D"/ca6-*.lua; do [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"; done
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
: > "$WORK/empty.map"

# build <page map> <out.docx>
build() {
  # shellcheck disable=SC2086 # FILTERS is a list of --lua-filter options, split on purpose
  (cd "$COURT" && CA6_DOCX_PAGES="$1" CA6_DOCX_LIST="$WORK/list.tsv" \
    pandoc --from markdown+smart --to docx --reference-doc="$REF" $FILTERS "$SAMPLE" -o "$2")
}

prev="$WORK/empty.map"
n=1
build "$prev" "$WORK/pass$n.docx" || exit 1
while :; do
  "$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$WORK" "$WORK/pass$n.docx" \
    > "$WORK/soffice$n.log" 2>&1 || {
    cat "$WORK/soffice$n.log" >&2
    exit 1
  }
  pdftotext -layout "$WORK/pass$n.pdf" "$WORK/pass$n.txt"
  pandoc lua "$D/pages.lua" "$WORK/pass$n.txt" "$WORK/list.tsv" > "$WORK/map$n.txt" || exit 1
  if cmp -s "$WORK/map$n.txt" "$prev"; then
    break
  fi
  if [ "$n" -ge 4 ]; then
    echo "docx/render.sh: the page numbers did not settle after $n passes" >&2
    exit 1
  fi
  prev="$WORK/map$n.txt"
  n=$((n + 1))
  build "$prev" "$WORK/pass$n.docx" || exit 1
done
unzip -tq "$WORK/pass$n.docx" > /dev/null || {
  echo "docx/render.sh: the docx is not a valid zip" >&2
  exit 1
}
cp "$WORK/pass$n.docx" "$OUT"
echo "$OUT"
