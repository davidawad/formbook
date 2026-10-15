#!/bin/sh
# DOCX build for the motion brief (this file owns the build; docs/EVAL-LOOP.md, "Engines"; called by tools/render-docx.sh).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
#
# The contents list needs page numbers, and only a layout knows them. So:
#   1. pandoc writes pass 1 with the contents unnumbered, and the sidecar (the headings, the first body words);
#   2. LibreOffice lays pass 1 out; the body page of each heading is found in that PDF (body page 1 is the page
#      where the body starts, counted from there);
#   3. pandoc writes pass 2 with those numbers in the contents;
#   4. LibreOffice lays pass 2 out and the body pages are found again: they must equal the numbers written.
# The numbers change the contents only, so the layout is the same; step 4 checks it for this sample.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FILTERS=""
for f in "$D"/*.lua; do FILTERS="$FILTERS --lua-filter=$f"; done
PANDOC_OPTS="--from markdown+smart --to docx --reference-doc=$D/reference.docx"

# pandoc renumbers the relationships of the reference's parts, but the section breaks in motion-brief.lua name the
# footer "rIdFtr1" (the reference's id). Point them at the id pandoc gave footer1.xml, then zip the package again.
fix_footer_ref() {
  X=$W/fix
  rm -rf "$X"
  mkdir -p "$X"
  unzip -q "$1" -d "$X"
  ID=$(grep 'footer1.xml' "$X/word/_rels/document.xml.rels" | sed -n 's/.*Id="\([^"]*\)".*/\1/p' | head -1)
  [ -n "$ID" ] || {
    echo "docx/render.sh: footer1.xml has no relationship in $1" >&2
    exit 1
  }
  sed -i "s/r:id=\"rIdFtr1\"/r:id=\"$ID\"/g" "$X/word/document.xml"
  rm -f "$1"
  (cd "$X" && zip -q -X -r "$1" .)
}

# layout <docx> <tag>: LibreOffice writes "$W/<tag>/<name>.pdf"; exits 1 if it fails.
layout() {
  mkdir -p "$W/$2"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile-$2" --headless --convert-to pdf --outdir "$W/$2" "$1" > "$W/$2.log" 2>&1 || {
    cat "$W/$2.log" >&2
    echo "docx/render.sh: LibreOffice failed on $1" >&2
    exit 1
  }
}

# body_pages <pdf> <tag>: prints the body page of each heading (sidecar order), counted from the body's first page.
body_pages() {
  pdf=$1
  tag=$2
  n=$(pdfinfo "$pdf" | awk '/^Pages:/ { print $2 }')
  mkdir -p "$W/text-$tag"
  p=1
  while [ "$p" -le "$n" ]; do
    pdftotext -f "$p" -l "$p" "$pdf" - | tr '\n' ' ' | tr -s ' ' | tr 'A-Z' 'a-z' > "$W/text-$tag/$p"
    p=$((p + 1))
  done
  awk -F '\t' '$1 == "B" { print $2 }' "$W/sidecar.txt" | tr -s ' ' | tr 'A-Z' 'a-z' > "$W/first.txt"
  awk -F '\t' '$1 == "H" { print $3 }' "$W/sidecar.txt" > "$W/headings.txt"
  start=""
  p=1
  while [ "$p" -le "$n" ]; do
    if grep -F -q -- "$(cat "$W/first.txt")" "$W/text-$tag/$p"; then
      start=$p
      break
    fi
    p=$((p + 1))
  done
  [ -n "$start" ] || {
    echo "docx/render.sh: the first body words were not found in $pdf" >&2
    exit 1
  }
  cur=$start
  while IFS= read -r words; do
    needle=$(printf '%s' "$words" | tr -s ' ' | tr 'A-Z' 'a-z')
    found=""
    q=$cur
    while [ "$q" -le "$n" ]; do
      if grep -F -q -- "$needle" "$W/text-$tag/$q"; then
        found=$q
        break
      fi
      q=$((q + 1))
    done
    [ -n "$found" ] || {
      echo "docx/render.sh: heading '$needle' was not found in $pdf" >&2
      exit 1
    }
    echo $((found - start + 1))
    cur=$found
  done < "$W/headings.txt"
}

# pass 1: the contents unnumbered; the sidecar gives the headings and the first body words
# shellcheck disable=SC2086
(cd "$COURT" && DCD_SIDECAR="$W/sidecar.txt" pandoc $PANDOC_OPTS $FILTERS "$SAMPLE" -o "$W/pass1.docx") || exit 1
fix_footer_ref "$W/pass1.docx"
layout "$W/pass1.docx" 1
body_pages "$W/1/pass1.pdf" 1 > "$W/toc-pages.txt"

# pass 2: the numbers in the contents; the layout must not move
# shellcheck disable=SC2086
(cd "$COURT" && DCD_TOC_PAGES="$W/toc-pages.txt" pandoc $PANDOC_OPTS $FILTERS "$SAMPLE" -o "$OUT") || exit 1
fix_footer_ref "$OUT"
layout "$OUT" 2
body_pages "$W/2/$(basename "${OUT%.docx}").pdf" 2 > "$W/check-pages.txt"
cmp -s "$W/toc-pages.txt" "$W/check-pages.txt" || {
  echo "docx/render.sh: the contents numbers do not match the layout of $OUT" >&2
  diff "$W/toc-pages.txt" "$W/check-pages.txt" >&2 || true
  exit 1
}
echo "$OUT"
