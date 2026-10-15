#!/bin/sh
# DOCX build for the casb adversary complaint (engine docx; docs/DOCX.md). Owns the .docx:
#   sh docx/render.sh <doc-dir> <sample.md, relative to the doc dir> <out.docx>
# 1. pandoc (markdown to docx) on docx/reference.docx with docx/casb-adversary-complaint.lua (the cover, the
#    numbered allegations, the lettered lists and the signature block);
# 2. the footer's placeholders (@FOOTER_TITLE@, @FOOTER_CASE@) are set from the sample's frontmatter
#    (footer_title and case_number), so no case text is in the template;
# 3. the package is rewritten as a zip and every XML part is checked.
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
CASE_NO=$(yq e '.case_number' "$W/fm.yaml")
for v in "$FOOTER_TITLE" "$CASE_NO"; do
  [ -n "$v" ] && [ "$v" != null ] || { echo "render.sh: the sample needs footer_title and case_number" >&2; exit 1; }
done
xesc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
FT=$(xesc "$FOOTER_TITLE")
FC=$(xesc "$CASE_NO")

pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/casb-adversary-complaint.lua" "$SAMPLE" -o "$W/stage.docx"
mkdir "$W/pkg" && (cd "$W/pkg" && unzip -q "$W/stage.docx")
found=0
for f in "$W/pkg"/word/footer*.xml; do
  [ -f "$f" ] || continue
  found=1
  sed -i -e "s|@FOOTER_TITLE@|$FT|" -e "s|@FOOTER_CASE@|$FC|" "$f"
  grep -q '@FOOTER' "$f" && { echo "render.sh: $f keeps a placeholder" >&2; exit 1; }
  xmllint --noout "$f"
done
[ "$found" = 1 ] || { echo "render.sh: the reference has no footer part" >&2; exit 1; }
for part in word/document.xml word/styles.xml word/header1.xml; do
  xmllint --noout "$W/pkg/$part" || { echo "render.sh: $part is not well-formed" >&2; exit 1; }
done
rm -f "$OUT"
(cd "$W/pkg" && ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null \
  && find . -type f ! -name '[[]Content_Types[]].xml' | sed 's|^\./||' | sort | while IFS= read -r f; do
    ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
  done)
unzip -tq "$OUT" > /dev/null
echo "$OUT"
