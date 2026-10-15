#!/bin/sh
# docx engine for this doc type (tools/render-docx.sh calls this when it exists): pandoc with reference.docx and
# txsd.lua, in two passes. Pass 1 lays the document out with LibreOffice; the page of every table-of-contents
# heading is read from that PDF; pass 2 writes those page numbers into the TOC field's cached results. The TOC
# field is also updatable in Word (Update Field); LibreOffice does not update PAGEREF fields on conversion.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# pass 1: no page numbers yet; the filter lists the headings it wrote
TXSD_TOC_LIST="$W/toc-list.txt" \
  sh -c 'cd "$1" && pandoc --from markdown+smart --to docx --reference-doc="$2/reference.docx" --lua-filter="$2/txsd.lua" "$3" -o "$4"' \
  sh "$COURT" "$D" "$SAMPLE" "$W/pass1.docx" || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice1.log" 2>&1 || {
  cat "$W/soffice1.log" >&2
  exit 1
}
PDF=$W/pass1.pdf

# the page of each heading: the first page after the previous heading's page that has the heading text, skipping
# the contents pages (they carry dot leaders or the title "TABLE OF CONTENTS")
N=$(pdfinfo "$PDF" | awk '/^Pages:/ { print $2 }')
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -f "$p" -l "$p" "$PDF" - | tr '\n' ' ' | tr -s ' ' > "$W/page-$p.txt"
  p=$((p + 1))
done
: > "$W/pages.txt"
cur=1
if [ -s "$W/toc-list.txt" ]; then
  while IFS=$(printf '\t') read -r id text; do
    found=""
    p=$cur
    while [ "$p" -le "$N" ]; do
      if ! grep -q -e 'TABLE OF CONTENTS' -e '\.\.\.\.' "$W/page-$p.txt" && grep -q -F -- "$text" "$W/page-$p.txt"; then
        found=$p
        break
      fi
      p=$((p + 1))
    done
    [ -n "$found" ] || {
      echo "render.sh: heading not found in the laid-out PDF: $text" >&2
      exit 1
    }
    printf '%s\t%s\n' "$id" "$found" >> "$W/pages.txt"
    cur=$found
  done < "$W/toc-list.txt"
fi

# pass 2: the same document with the page numbers
TXSD_TOC_PAGES="$W/pages.txt" \
  sh -c 'cd "$1" && pandoc --from markdown+smart --to docx --reference-doc="$2/reference.docx" --lua-filter="$2/txsd.lua" "$3" -o "$4"' \
  sh "$COURT" "$D" "$SAMPLE" "$OUT"
echo "$OUT"
