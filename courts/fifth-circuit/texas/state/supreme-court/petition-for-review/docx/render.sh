#!/bin/sh
# DOCX build for this doc type (docs/DOCX.md): pandoc on reference.docx with docx/tex.lua, in two passes.
# Pass 1 marks each contents entry's heading (a hidden marker); LibreOffice lays it out and the page label of each
# marker is read from that PDF (the footer: roman in the front matter, arabic in the body). Pass 2 writes those
# labels into the contents as the cached result of each PAGEREF. A marker missing from the PDF fails the build.
# Usage: sh docx/render.sh <doc-type-dir> <sample.md> <out.docx>   (called by tools/render-docx.sh)
set -eu
DT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D="$DT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
build() { (cd "$DT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/tex.lua" "$SAMPLE" -o "$1"); }

DOCX_TOC_MARKS=1 build "$W/pass1.docx" || { echo "render.sh: pass 1 failed" >&2; exit 1; }
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
N=$(pdfinfo "$W/pass1.pdf" | awk '/^Pages:/ { print $2 }')
: > "$W/marks.txt"
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -layout -f "$p" -l "$p" "$W/pass1.pdf" "$W/page.txt"
  label=$(grep -v '^[[:space:]]*$' "$W/page.txt" | tail -n 1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  case $label in
    [0-9]*|[ivxlc]*) ;;
    *) label="" ;; # the cover has no footer: its markers would be missing (the pass 2 check fails)
  esac
  [ -n "$label" ] && grep -o "TOCMARK[0-9]*" "$W/page.txt" | sed "s/^TOCMARK//" | while IFS= read -r k; do
    printf '%s\t%s\n' "$k" "$label"
  done >> "$W/marks.txt" || true
  p=$((p + 1))
done
awk -F'\t' '!seen[$1]++' "$W/marks.txt" > "$W/pages.txt"

DOCX_TOC_PAGES="$W/pages.txt" build "$W/pass2.docx" || { echo "render.sh: pass 2 failed (a contents entry has no page in the PDF)" >&2; exit 1; }
cp "$W/pass2.docx" "$OUT"
