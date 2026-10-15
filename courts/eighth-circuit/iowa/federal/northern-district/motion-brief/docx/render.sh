#!/bin/sh
# Builds the memorandum's .docx (docs/DOCX.md). tools/render-docx.sh calls it as: render.sh <court-dir> <sample.md> <out.docx>
# The table of contents needs page numbers, so the build runs twice:
#   pass 1: pandoc writes the .docx and the entries it needs (DOCX_TOC_LIST); LibreOffice makes its PDF;
#           the page of each entry is the first page, from the body's first page on, whose text holds the heading.
#   pass 2: pandoc writes the final .docx with those page numbers (DOCX_PAGES).
# A heading that is not found in the PDF fails the build (no page number is invented).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
PANDOC="pandoc --from markdown+smart --to docx --reference-doc=$D/reference.docx --lua-filter=$D/motion-brief.lua"

# pass 1
DOCX_TOC_LIST="$W/toc.tsv" $PANDOC "$SAMPLE" -o "$W/pass1.docx"
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
PAGES=$(pdfinfo "$W/pass1.pdf" | awk '/^Pages:/ {print $2}')
i=1
while [ "$i" -le "$PAGES" ]; do
  # the page's text without spaces, case and punctuation, so a heading matches across its line breaks
  pdftotext -f "$i" -l "$i" "$W/pass1.pdf" - | tr -cd 'A-Za-z0-9' | tr 'A-Z' 'a-z' > "$W/page-$i.txt"
  i=$((i + 1))
done

: > "$W/pages.txt"
cur=1
while IFS= read -r line; do
  level=$(printf '%s' "$line" | cut -f1)
  text=$(printf '%s' "$line" | cut -f2-)
  key=$(printf '%s' "$text" | tr -cd 'A-Za-z0-9' | tr 'A-Z' 'a-z' | cut -c1-30)
  found=0
  page=$cur
  while [ "$page" -le "$PAGES" ]; do
    if grep -q -F -- "$key" "$W/page-$page.txt"; then
      found=$page
      break
    fi
    page=$((page + 1))
  done
  if [ "$found" -eq 0 ]; then
    echo "render.sh: no page of the PDF holds the heading: $text" >&2
    exit 1
  fi
  cur=$found
  # level 0 is the body's first paragraph: it only marks where the entries start
  if [ "$level" != 0 ]; then echo "$found" >> "$W/pages.txt"; fi
done < "$W/toc.tsv"

# pass 2
DOCX_PAGES="$W/pages.txt" $PANDOC "$SAMPLE" -o "$OUT"
