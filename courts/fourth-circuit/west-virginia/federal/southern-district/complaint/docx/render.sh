#!/bin/sh
# DOCX engine for the wvsd complaint (called by tools/render-docx.sh): sh docx/render.sh <court-dir> <sample.md> <out.docx>
# Two passes, so that the table of contents carries the real page numbers as cached PAGEREF results
# (Word shows them before any field update; LibreOffice computes them too):
#   pass 1: pandoc -> pass1.docx, the heading entries are written by the filter; soffice -> pass1.pdf;
#   pages:  each entry is found on its page of pass1.pdf (body numbering starts at the page with the lead-in);
#   pass 2: pandoc -> out.docx with the page numbers from the first pass (env WVSD_PAGES).
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
FILTERS=""
for f in "$D"/*.lua; do [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"; done
: > "$W/pages.tsv"
(cd "$COURT" && WVSD_PAGES="$W/pages.tsv" WVSD_TOC_OUT="$W/entries.tsv" \
  pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS "$SAMPLE" -o "$W/pass1.docx")
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
N=$(pdfinfo "$W/pass1.pdf" | sed -n 's/^Pages: *//p')
# body starts at the page with the lead-in (the cover and the table of contents come before it)
body=""
p=1
while [ "$p" -le "$N" ]; do
  if pdftotext -layout -f "$p" -l "$p" "$W/pass1.pdf" - | tr '\n' ' ' | tr -s ' ' | grep -q 'TO THE HONORABLE COURT'; then
    body=$p
    break
  fi
  p=$((p + 1))
done
[ -n "$body" ] || {
  echo "render.sh: the lead-in was not found in the first pass" >&2
  exit 1
}
# the text of each body page, one line per page, whitespace collapsed
: > "$W/pagetext.txt"
p=$body
while [ "$p" -le "$N" ]; do
  pdftotext -layout -f "$p" -l "$p" "$W/pass1.pdf" - | tr '\n' ' ' | tr -s ' ' >> "$W/pagetext.txt"
  echo >> "$W/pagetext.txt"
  p=$((p + 1))
done
while IFS="$(printf '\t')" read -r bm level label text; do
  needle=$(printf '%s %s' "$label" "$text" | tr -s ' ')
  found=""
  i=1
  while IFS= read -r line; do
    if printf '%s' "$line" | grep -F -q -- "$needle"; then
      found=$i
      break
    fi
    i=$((i + 1))
  done < "$W/pagetext.txt"
  [ -n "$found" ] || {
    echo "render.sh: heading not found in the first pass: $needle" >&2
    exit 1
  }
  printf '%s\t%s\n' "$bm" "$found" >> "$W/pages.tsv"
done < "$W/entries.tsv"
(cd "$COURT" && WVSD_PAGES="$W/pages.tsv" \
  pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS "$SAMPLE" -o "$OUT")
echo "$OUT" >&2
