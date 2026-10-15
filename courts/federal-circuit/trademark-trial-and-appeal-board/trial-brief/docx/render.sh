#!/bin/sh
# render.sh <doc-dir> <sample.md> <out.docx>: the brief's .docx, with the table of authorities's page numbers.
# Called by tools/render-docx.sh (docs/DOCX.md). pandoc cannot compute page numbers, so the conversion runs until the
# numbers settle: each pass converts the .docx to PDF with LibreOffice, finds the body pages of every authority
# (toa-pages.sh), and the next pass lists them. A pass whose numbers equal the previous pass's is the output.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
SOFFICE=${SOFFICE:-soffice}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
FILTERS=""
for f in "$D"/*.lua; do [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"; done
pass=0
while :; do
  pass=$((pass + 1))
  rm -f "$T/out.docx" "$T/out.pdf"
  : > "$T/search"
  # shellcheck disable=SC2086 # FILTERS is a list of --lua-filter options, split on purpose
  (cd "$COURT" && TTAB_TOA_SEARCH="$T/search" TTAB_TOA_PAGES="$T/pages" pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" $FILTERS "$SAMPLE" -o "$T/out.docx") || exit 1
  "$SOFFICE" "-env:UserInstallation=file://$T/profile" --headless --convert-to pdf --outdir "$T" "$T/out.docx" > "$T/soffice.log" 2>&1 || {
    cat "$T/soffice.log" >&2
    exit 1
  }
  [ -f "$T/out.pdf" ] || {
    echo "render.sh: LibreOffice wrote no PDF" >&2
    exit 1
  }
  sh "$D/toa-pages.sh" "$T/out.pdf" "$T/search" > "$T/pages.new"
  if [ -f "$T/pages" ] && cmp -s "$T/pages" "$T/pages.new"; then
    break
  fi
  cp "$T/pages.new" "$T/pages"
  if [ "$pass" -ge 4 ]; then
    echo "render.sh: the table of authorities did not settle after $pass passes" >&2
    exit 1
  fi
done
cp "$T/out.docx" "$OUT"
