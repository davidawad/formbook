#!/bin/sh
# S.D.N.Y. motion brief, DOCX engine: the .docx with its page numbers in the tables of contents and authorities.
# Usage (called by tools/render-docx.sh): sh docx/render.sh <court-dir> <sample.md> <out.docx>
# Pass 1: pandoc writes the .docx with placeholder page numbers and the search keys (NYSD_MB_DATA);
# LibreOffice converts it to PDF; pages.awk finds the printed page of each heading and authority in the body.
# Pass 2: pandoc writes the .docx again with those page numbers (NYSD_MB_PAGES). The body text is the same in
# both passes, so the pages found in pass 1 hold in pass 2. Needs pandoc, soffice, pdftotext, gawk.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
SOFF=${SOFFICE:-soffice}
NYSD_MB_DATA="$W/data.txt" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/motion-brief.lua" "$COURT/$SAMPLE" -o "$W/p1.docx"
"$SOFF" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/p1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
pdftotext -enc UTF-8 "$W/p1.pdf" - > "$W/p1.txt"
LC_ALL=C gawk -v DATA="$W/data.txt" -f "$D/pages.awk" "$W/p1.txt" > "$W/pages.txt" || {
  echo "docx/render.sh: page numbers not found (see messages above)" >&2
  exit 1
}
NYSD_MB_PAGES="$W/pages.txt" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/motion-brief.lua" "$COURT/$SAMPLE" -o "$OUT"
echo "$OUT"
