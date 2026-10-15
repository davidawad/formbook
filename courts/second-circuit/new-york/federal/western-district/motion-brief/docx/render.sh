#!/bin/sh
# nywd memorandum of law, DOCX engine: builds the .docx with the table of contents' page numbers (docs/DOCX.md).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Called by tools/render-docx.sh, which then converts <out.docx> to PDF with LibreOffice.
# Pass 1 writes the headings (NYWD_TOC_LIST) and a table of contents without numbers; LibreOffice converts it to
# PDF; each heading is found in the PDF after the table of contents, and its page number (counted from the body,
# which starts at 1) goes to a file (NYWD_TOC_PAGES). Pass 2 writes the final .docx with those numbers.
# Fails, writing nothing, if a heading cannot be found in the PDF.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

build() { # $1 = out.docx, $2 = page-number file (or /dev/null), $3 = heading-list file (or /dev/null)
  (cd "$COURT" && NYWD_TOC_PAGES="$2" NYWD_TOC_LIST="$3" pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$D/nywd-motion-brief.lua" "$SAMPLE" -o "$1")
}

build "$W/pass1.docx" /dev/null "$W/headings.txt" || { echo "render.sh: pass 1 failed" >&2; exit 1; }
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
PDF=$W/pass1.pdf
N=$(pdfinfo "$PDF" | awk '/^Pages:/ { print $2 }')
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -f "$p" -l "$p" "$PDF" - | tr '\n' ' ' | tr -s ' ' > "$W/page-$p.txt"
  tr -d ' -' < "$W/page-$p.txt" > "$W/key-$p.txt"
  p=$((p + 1))
done

# the table of contents: from the first page that has the heading, through the pages of leader dots
first=""
p=1
while [ "$p" -le "$N" ]; do
  if grep -q "TABLE OF CONTENTS" "$W/page-$p.txt"; then first=$p; break; fi
  p=$((p + 1))
done
[ -n "$first" ] || { echo "render.sh: no table of contents in the PDF" >&2; exit 1; }
body=$first
while [ "$body" -le "$N" ] && grep -q '\.\.\.\.\.' "$W/page-$body.txt"; do body=$((body + 1)); done
[ "$body" -le "$N" ] || { echo "render.sh: no body after the table of contents" >&2; exit 1; }

: > "$W/pages.txt"
start=$body
while IFS= read -r h; do
  [ -n "$h" ] || continue
  needle=$(printf '%s' "$h" | tr -d ' -')
  q=$start
  found=""
  while [ "$q" -le "$N" ]; do
    if grep -q -F -- "$needle" "$W/key-$q.txt"; then
      found=$q
      break
    fi
    q=$((q + 1))
  done
  [ -n "$found" ] || { echo "render.sh: heading not found in the PDF: $needle" >&2; exit 1; }
  echo $((found - body + 1)) >> "$W/pages.txt"
  start=$found
done < "$W/headings.txt"

build "$OUT" "$W/pages.txt" /dev/null || { echo "render.sh: pass 2 failed" >&2; exit 1; }
