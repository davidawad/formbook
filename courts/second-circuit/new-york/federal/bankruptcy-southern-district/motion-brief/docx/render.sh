#!/bin/sh
# nysb motion memorandum, DOCX engine: builds the .docx for tools/render-docx.sh (docs/DOCX.md, "Engines").
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>
# Two passes, because the contents page lists the page of every heading and only a layout can say where that is:
#   pass 1: pandoc writes the search keys (the first body paragraph, then each heading) and a .docx with blank page numbers;
#           LibreOffice makes its PDF; the PDF pages are searched in order for each key (from the first body page on).
#   pass 2: pandoc writes the .docx with the page numbers (body pages count from 1, after the cover and the contents).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
SOFFICE=${SOFFICE:-soffice}
LUA="--lua-filter=$D/nysb-motion-brief.lua"
REF="--reference-doc=$D/reference.docx"

cd "$COURT"
NYSB_KEYS="$W/keys" pandoc --from markdown+smart --to docx "$REF" "$LUA" "$SAMPLE" -o "$W/pass1.docx"
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
pdftotext "$W/pass1.pdf" "$W/pass1.txt"
# pages: "index<TAB>page" for each heading; the body starts at the first page holding the first body paragraph
awk -v keys="$W/keys" '
BEGIN {
  RS = "\n"; n = 0
  while ((getline line < keys) > 0) { n++; k[n] = line }
  close(keys)
  RS = "\f"; body = 0; idx = 2
}
{
  s = tolower($0); gsub(/[^a-z0-9]/, "", s)
  if (body == 0) {
    if (index(s, k[1]) == 0) next
    body = NR
  }
  while (idx <= n && index(s, k[idx]) > 0) { page[idx - 1] = NR - body + 1; idx++ }
}
END {
  for (i = 1; i < n; i++) print i "\t" ((i in page) ? page[i] : 0)
}' "$W/pass1.txt" > "$W/pages"

NYSB_TOC_PAGES="$W/pages" pandoc --from markdown+smart --to docx "$REF" "$LUA" "$SAMPLE" -o "$OUT"
echo "$OUT"
