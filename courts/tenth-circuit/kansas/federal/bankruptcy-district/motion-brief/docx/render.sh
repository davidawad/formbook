#!/bin/sh
# Renders the ksb motion brief (memorandum) to a .docx in two passes (docs/DOCX.md, "Table of contents" and
# "Table of authorities": Word and LibreOffice do not fill those fields by themselves, so the page numbers are
# found in a first-pass PDF and written into the second pass).
#   pass 1: pandoc + ksb.lua writes the search phrases (KSB_SEARCH) and placeholder page numbers; LibreOffice makes a PDF.
#   pass 2: pages.lua (pandoc lua) finds each heading and each authority in that PDF; pandoc + ksb.lua writes them (KSB_PAGES).
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>   (called by tools/render-docx.sh)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
DOCX=$3
case $DOCX in /*) ;; *) DOCX=$(pwd)/$DOCX ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}

(cd "$COURT" && KSB_SEARCH="$W/search.tsv" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/ksb.lua" "$SAMPLE" -o "$W/pass1.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" \
  > "$W/soffice.log" 2>&1 || { cat "$W/soffice.log" >&2; exit 1; }

N=$(pdfinfo "$W/pass1.pdf" | sed -n 's/^Pages: *//p')
PAGES=""
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -f "$p" -l "$p" "$W/pass1.pdf" - | tr '\n' ' ' > "$W/page-$p.txt"
  PAGES="$PAGES $W/page-$p.txt"
  p=$((p + 1))
done
# shellcheck disable=SC2086
pandoc lua "$D/pages.lua" "$W/search.tsv" $PAGES > "$W/pages.tsv" || exit 1

(cd "$COURT" && KSB_PAGES="$W/pages.tsv" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/ksb.lua" "$SAMPLE" -o "$DOCX") || exit 1
echo "$DOCX"
