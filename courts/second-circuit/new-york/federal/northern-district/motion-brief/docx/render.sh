#!/bin/sh
# nynd memorandum of law, DOCX engine: builds the .docx for one sample (docs/DOCX.md, "Known limits").
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# The markdown is read as CommonMark (commonmark_x, as cmarker reads it in typst): a literal "*" is not emphasis.
# Called by tools/render-docx.sh, which then converts the .docx to the LibreOffice PDF.
# Two passes. Pass 1 lays the memorandum out with placeholder page numbers in the table of contents and writes
# the heading list. LibreOffice converts it; each heading's page label (the arabic footer number, cover and
# contents excluded) is read from that PDF. Pass 2 writes the same document with those numbers in the contents.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap '[ -n "${NYND_KEEP:-}" ] || rm -rf "$W"' EXIT
REF="$D/reference.docx"
[ -f "$REF" ] || { echo "render.sh: missing $REF (run docx/build-reference.sh)" >&2; exit 1; }

# pass 1: placeholders in the contents; the heading list goes to heads.tsv
NYND_TOC_MAP= NYND_TOC_LIST="$W/heads.tsv" pandoc --from commonmark_x-fancy_lists+smart --to docx \
  --reference-doc="$REF" --lua-filter="$D/nynd-motion-brief.lua" "$COURT/$SAMPLE" -o "$W/pass1.docx" || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" \
  > "$W/soffice.log" 2>&1 || { cat "$W/soffice.log" >&2; exit 1; }

# the page text of each physical page, with a marker line before each page
n=$(pdfinfo "$W/pass1.pdf" | awk '/^Pages:/ { print $2 }')
: > "$W/pages.txt"
p=1
while [ "$p" -le "$n" ]; do
  echo "@@PAGE" >> "$W/pages.txt"
  pdftotext -f "$p" -l "$p" -layout "$W/pass1.pdf" - | tr -d '\f' >> "$W/pages.txt"
  p=$((p + 1))
done

# for each heading, in order: the footer label of the first body page (arabic label) where its line appears
NH=$(wc -l < "$W/heads.tsv")
awk -F '\t' '
  BEGIN { hi = 1 }
  function norm(s) { s = tolower(s); gsub(/[ \t\r]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
  function head_on_line(L, H) { return (L == H) || (length(L) >= 20 && index(H, L) == 1) }
  function flush(   k, lab, s) {
    if (np == 0) return
    lab = ""
    for (k = np; k >= 1; k--) { s = norm(P[k]); if (s != "") { lab = s; break } }
    if (lab ~ /^[0-9]+$/) {
      while (hi <= nh) {
        found = 0
        for (k = 1; k <= np; k++) if (head_on_line(norm(P[k]), H[hi])) { found = 1; break }
        if (!found) break
        print lab
        hi++
      }
    }
    np = 0
  }
  FNR == NR { nh++; H[nh] = norm($2); next }
  /^@@PAGE$/ { flush(); next }
  { P[++np] = $0 }
  END { flush(); if (hi <= nh) { print "render.sh: heading not found in the PDF: " H[hi] > "/dev/stderr"; exit 1 } }
' "$W/heads.tsv" "$W/pages.txt" > "$W/map.txt" || exit 1
[ "$(wc -l < "$W/map.txt")" -eq "$NH" ] || { echo "render.sh: found $(wc -l < "$W/map.txt") of $NH headings" >&2; exit 1; }

# pass 2: the contents with the page numbers
NYND_TOC_MAP="$W/map.txt" pandoc --from commonmark_x-fancy_lists+smart --to docx \
  --reference-doc="$REF" --lua-filter="$D/nynd-motion-brief.lua" "$COURT/$SAMPLE" -o "$OUT" || exit 1
echo "$OUT"
