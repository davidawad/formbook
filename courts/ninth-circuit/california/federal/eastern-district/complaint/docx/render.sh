#!/bin/sh
# DOCX build for the E.D. Cal. complaint (caed), engine docx (docs/DOCX.md). Owns the .docx:
#   sh docx/render.sh <doc-dir> <sample.md, relative to the doc dir> <out.docx>
# 1. pandoc (markdown -> docx) on docx/reference.docx with docx/caed-complaint.lua (cover, numbering, signature);
# 2. the footer's description is set from the sample's frontmatter (footer_title): the placeholder
#    @FOOTER_TITLE@ in word/footer*.xml is replaced (the reference cannot know it);
# 3. every XML part is checked and the package is rewritten as a zip.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
cd "$COURT"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

awk 'BEGIN { n = 0 } /^---[ \t]*$/ && n < 2 { n++; next } n == 1' "$SAMPLE" > "$W/fm.yaml"
FOOTER_TITLE=$(yq e '.footer_title' "$W/fm.yaml")
[ -n "$FOOTER_TITLE" ] && [ "$FOOTER_TITLE" != null ] || { echo "render.sh: the sample needs footer_title" >&2; exit 1; }
xesc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
FT=$(xesc "$FOOTER_TITLE")

pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/caed-complaint.lua" "$SAMPLE" -o "$W/stage.docx"
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/stage.docx"
for f in word/footer*.xml; do
  [ -f "$f" ] || continue
  sed -i -e "s|@FOOTER_TITLE@|$FT|" "$f"
  grep -q '@FOOTER' "$f" && { echo "render.sh: $f keeps a placeholder" >&2; exit 1; }
  xmllint --noout "$f"
done
for part in word/document.xml word/styles.xml word/header1.xml; do
  [ -f "$part" ] && xmllint --noout "$part"
done
rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find . -type f ! -name '[[]Content_Types[]].xml' | sed 's|^\./||' | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
