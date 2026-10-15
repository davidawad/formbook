#!/bin/sh
# DOCX engine for the BIA brief on appeal. Owns the .docx: tools/render-docx.sh calls
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Two passes, so the table of contents shows page numbers without a field update:
#   pass 1: pandoc (reference.docx + bia.lua) -> LibreOffice PDF; each heading's page is found in the PDF;
#   pass 2: pandoc again with those page numbers -> the .docx; the A-number goes into the footer.
# Needs: pandoc, soffice, pdfinfo, pdftotext, unzip, zip, awk, sed.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# the A-number from the frontmatter (the same field the typst footer reads); XML-escaped for the footer
A=$(awk 'NR == 1 && /^---$/ { f = 1; next } f && /^---$/ { exit } f && /^a_number:/ { sub(/^a_number: */, ""); gsub(/^"|"$/, ""); print; exit }' "$COURT/$SAMPLE")
A=$(printf '%s' "$A" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[\/|]/\\&/g')

# build <out.docx> <toc-pages file, or empty>
build() {
  rm -rf "$W/pkg"
  mkdir "$W/pkg"
  (cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/bia.lua" -M "bia_toc=$2" "$SAMPLE" -o "$1") || return 1
  (cd "$W/pkg" && unzip -q "$1") || return 1
  for f in "$W"/pkg/word/footer*.xml; do
    [ -f "$f" ] || continue
    sed -i "s|__A_NUMBER__|$A|g" "$f"
  done
  rm -f "$1"
  (cd "$W/pkg" && zip -q -X -r "$1" '[Content_Types].xml' _rels docProps word) || return 1
}

# pass 1
build "$W/p1.docx" "" || {
  echo "render.sh: pass 1 (pandoc) failed" >&2
  exit 1
}
PROFILE="-env:UserInstallation=file://$W/profile"
"$SOFFICE" "$PROFILE" --headless --convert-to pdf --outdir "$W" "$W/p1.docx" > "$W/soffice1.log" 2>&1 ||
  "$SOFFICE" "$PROFILE" --headless --convert-to pdf --outdir "$W" "$W/p1.docx" > "$W/soffice1.log" 2>&1 || {
  cat "$W/soffice1.log" >&2
  echo "render.sh: LibreOffice pass 1 failed" >&2
  exit 1
}
[ -f "$W/p1.pdf" ] || {
  echo "render.sh: LibreOffice wrote no PDF for pass 1" >&2
  exit 1
}

# heading pages: the headings are the ATX headings of the sample (levels 1 and 2), in order. The body numbering
# starts at the Introduction, which is physical page 3 (cover = 1, contents = 2), so the number shown is page - 2.
grep -E '^#{1,2} ' "$COURT/$SAMPLE" | sed -E 's/^#{1,2} +//; s/[*_]//g' > "$W/heads.txt"
N=$(pdfinfo "$W/p1.pdf" | awk '/^Pages:/ { print $2 }')
: > "$W/toc.txt"
start=3
while IFS= read -r h; do
  found=""
  q=$start
  while [ -z "$found" ] && [ "$q" -le "$N" ]; do
    if pdftotext -f "$q" -l "$q" -layout "$W/p1.pdf" - | awk -v h="$h" '
        BEGIN { t = tolower(h) }
        # a heading may wrap onto two lines: compare the line, and the line joined to the one before it
        { s = $0; gsub(/^[ \t]+|[ \t]+$/, "", s); if (tolower(s) == t || tolower(p " " s) == t) hit = 1; p = s }
        END { exit !hit }'; then
      found=$q
    fi
    q=$((q + 1))
  done
  [ -n "$found" ] || {
    echo "render.sh: heading not found in pass 1 PDF: $h" >&2
    exit 1
  }
  echo $((found - 2)) >> "$W/toc.txt"
  start=$found
done < "$W/heads.txt"

# pass 2: the final .docx
build "$W/p2.docx" "$W/toc.txt" || {
  echo "render.sh: pass 2 (pandoc) failed" >&2
  exit 1
}
cp "$W/p2.docx" "$OUT"
echo "$OUT"
