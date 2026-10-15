#!/bin/sh
# docx/render.sh <court-dir> <sample.md> <out.docx>: builds the memorandum .docx for tools/render-docx.sh.
# The table of contents and table of authorities carry page numbers, so the build runs in passes: pass 1 writes
# the search keys and renders the .docx with LibreOffice; pages.awk finds each heading and authority in that PDF;
# the next pass writes those numbers. The passes repeat until the numbers do not change (at most 4).
# A heading or authority that is not found stops the build (MISSING lines are printed).
# Needs: pandoc, soffice (LibreOffice), pdftotext, gawk. FONTCONFIG_FILE is set to docx/fonts.conf here (EB Garamond).
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo soffice)}
[ -f "$HERE/reference.docx" ] || { echo "render.sh: $HERE/reference.docx missing (run docx/build-reference.sh)" >&2; exit 1; }
export FONTCONFIG_FILE=${FONTCONFIG_FILE:-$HERE/fonts.conf}
export LC_ALL=C
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
NAME=$(basename "$SAMPLE" .md)

build() { # $1 = pages file ("" on pass 1), $2 = out.docx
  (cd "$COURT" && MTD_KEYS="$W/keys.tsv" MTD_PAGES="$1" pandoc --from markdown+smart --to docx \
    --reference-doc="$HERE/reference.docx" --lua-filter="$HERE/mtd-motion-brief.lua" "$SAMPLE" -o "$2") || exit 1
}

pdf_of() { # $1 = docx, $2 = pass number: LibreOffice PDF in $W
  d="$W/pdf$2"
  mkdir -p "$d"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$d" "$1" > "$W/soffice$2.log" 2>&1 || {
    cat "$W/soffice$2.log" >&2
    exit 1
  }
  echo "$d/$(basename "${1%.docx}").pdf"
}

used=""
i=0
while :; do
  i=$((i + 1))
  [ "$i" -le 4 ] || {
    echo "render.sh: the table of contents and authorities did not settle after 4 passes" >&2
    exit 1
  }
  build "$used" "$W/pass$i.docx"
  pdf=$(pdf_of "$W/pass$i.docx" "$i")
  pdftotext "$pdf" "$W/pass$i.txt"
  gawk -f "$HERE/pages.awk" "$W/keys.tsv" "$W/pass$i.txt" > "$W/pages$i.tsv" || {
    grep '^MISSING' "$W/pages$i.tsv" >&2
    echo "render.sh: a heading or authority was not found in the PDF (see MISSING above)" >&2
    exit 1
  }
  if [ -n "$used" ] && cmp -s "$W/pages$i.tsv" "$used"; then
    cp "$W/pass$i.docx" "$OUT"
    echo "render.sh: $NAME settled after $i pass(es)" >&2
    exit 0
  fi
  used="$W/pages$i.tsv"
  cp "$used" "$W/keep-pages.tsv"
done
