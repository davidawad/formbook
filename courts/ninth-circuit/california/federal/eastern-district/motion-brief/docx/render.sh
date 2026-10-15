#!/bin/sh
# DOCX build for the E.D. Cal. motion (caed motion-brief), engine docx (docs/DOCX.md). Owns the .docx:
#   sh docx/render.sh <doc-dir> <sample.md, relative to the doc dir> <out.docx>
# 1. pandoc (markdown -> docx) on docx/reference.docx with docx/caed-motion-brief.lua (cover, notice, tables,
#    memorandum, section breaks for the page-number formats);
# 2. the footer's description is set from footer_title in the sample's frontmatter (the reference cannot know it);
# 3. the table of contents page numbers: the docx is converted once with LibreOffice, each memorandum heading
#    is found on its page (memorandum page 1 is the page after the table of authorities' pages), the numbers
#    are written into @PG<n>@, and the docx is built again; a third conversion must give the same numbers;
# 4. every section break gets the header and footer references (fix-sections.pl); every XML part is checked.
set -eu
export LC_ALL=C.UTF-8
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"

awk 'BEGIN { n = 0 } /^---[ \t]*$/ && n < 2 { n++; next } n == 1' "$SAMPLE" > "$W/fm.yaml"
FOOTER_TITLE=$(yq e '.footer_title' "$W/fm.yaml")
MEMO_TITLE=$(yq e '.memo_title' "$W/fm.yaml" | tr 'a-z' 'A-Z')
[ -n "$FOOTER_TITLE" ] && [ "$FOOTER_TITLE" != null ] || { echo "render.sh: the sample needs footer_title" >&2; exit 1; }
[ -n "$MEMO_TITLE" ] && [ "$MEMO_TITLE" != null ] || { echo "render.sh: the sample needs memo_title" >&2; exit 1; }
xesc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
FT=$(xesc "$FOOTER_TITLE")

# memorandum headings, in order (the same rule as caed-motion-brief.lua: the headings after [[MEMO]])
awk '/^\[\[MEMO\]\]/ { on = 1; next } on && /^#/ { sub(/^#+[ \t]*/, ""); print }' "$SAMPLE" > "$W/heads.txt"
NH=$(wc -l < "$W/heads.txt" | tr -d ' ')

# build <out.docx> <pagemap or empty>: one pandoc build with the placeholders filled
build() {
  B=$1
  M=$2
  rm -rf "$W/pkg" "$W/stage.docx"
  pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/caed-motion-brief.lua" "$SAMPLE" -o "$W/stage.docx"
  mkdir "$W/pkg" && (cd "$W/pkg" && unzip -q "$W/stage.docx")
  (
    cd "$W/pkg"
    for f in word/footer*.xml; do
      [ -f "$f" ] || continue
      sed -i -e "s|@FOOTER_TITLE@|$FT|" "$f"
      grep -q '@FOOTER' "$f" && { echo "render.sh: $f keeps a placeholder" >&2; exit 1; }
      xmllint --noout "$f"
    done
    if [ -n "$M" ]; then
      i=1
      while [ "$i" -le "$NH" ]; do
        PG=$(awk -v n="$i" '$1 == n { print $2 }' "$M")
        [ -n "$PG" ] || { echo "render.sh: no page for heading $i" >&2; exit 1; }
        sed -i "s|@PG$i@|$PG|g" word/document.xml
        i=$((i + 1))
      done
    fi
    [ -n "$M" ] || sed -i 's|@PG[0-9]*@|00|g' word/document.xml
    grep -q '@PG' word/document.xml && { echo "render.sh: a table of contents placeholder is left" >&2; exit 1; }
    perl "$D/fix-sections.pl" word/document.xml
    for part in word/document.xml word/styles.xml word/header1.xml word/footer1.xml; do
      [ -f "$part" ] && xmllint --noout "$part"
    done
    rm -f "$B"
    ziptool -n "$B" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
    find . -type f ! -name '[[]Content_Types[]].xml' | sed 's|^\./||' | sort | while IFS= read -r f; do
      ziptool "$B" add_file "$f" "$f" 0 0 > /dev/null
    done
  )
  unzip -tq "$B" > /dev/null
}

# pages <docx> <pdf-dir> <pagemap-out>: convert with LibreOffice and find each memorandum heading's page
pages() {
  X=$1
  PD=$2
  MO=$3
  mkdir -p "$PD/profile"
  "$SOFFICE" "-env:UserInstallation=file://$PD/profile" --headless --convert-to pdf --outdir "$PD" "$X" > "$PD/soffice.log" 2>&1 || { cat "$PD/soffice.log" >&2; exit 1; }
  P="$PD/$(basename "${X%.docx}").pdf"
  N=$(pdfinfo "$P" | awk '/^Pages:/ { print $2 }')
  # the memorandum's first page: the first page after page 1 with the title on a line of its own
  MS=""
  p=2
  while [ "$p" -le "$N" ]; do
    if pdftotext -f "$p" -l "$p" "$P" - | sed 's/^[ \t]*//; s/[ \t]*$//' | grep -qxF "$MEMO_TITLE"; then MS=$p; break; fi
    p=$((p + 1))
  done
  [ -n "$MS" ] || { echo "render.sh: the memorandum title is not on any page" >&2; exit 1; }
  : > "$MO"
  p=$MS
  while [ "$p" -le "$N" ]; do
    pdftotext -f "$p" -l "$p" "$P" - | sed -e '/^[0-9]*$/d' -e 's/ﬁ/fi/g; s/ﬂ/fl/g; s/ﬀ/ff/g; s/ﬃ/ffi/g; s/ﬄ/ffl/g' | tr -cd 'A-Za-z0-9' | tr 'A-Z' 'a-z' > "$PD/page-$p.txt"
    p=$((p + 1))
  done
  i=1
  start=$MS
  while [ "$i" -le "$NH" ]; do
    KEY=$(sed -n "${i}p" "$W/heads.txt" | sed -e 's/ﬁ/fi/g; s/ﬂ/fl/g' | tr -cd 'A-Za-z0-9' | tr 'A-Z' 'a-z')
    [ -n "$KEY" ] || { echo "render.sh: heading $i has no text" >&2; exit 1; }
    found=""
    p=$start
    while [ "$p" -le "$N" ]; do
      if grep -qF "$KEY" "$PD/page-$p.txt"; then found=$p; break; fi
      p=$((p + 1))
    done
    [ -n "$found" ] || { echo "render.sh: heading $i ($KEY) is not found in the memorandum" >&2; exit 1; }
    echo "$i $((found - MS + 1))" >> "$MO"
    start=$found
    i=$((i + 1))
  done
}

build "$W/p1.docx" ""
pages "$W/p1.docx" "$W/pdf1" "$W/map1.txt"
build "$W/p2.docx" "$W/map1.txt"
pages "$W/p2.docx" "$W/pdf2" "$W/map2.txt"
cmp -s "$W/map1.txt" "$W/map2.txt" || { echo "render.sh: the table of contents page numbers moved on the second build" >&2; exit 1; }
cp "$W/p2.docx" "$OUT"
echo "$OUT"
