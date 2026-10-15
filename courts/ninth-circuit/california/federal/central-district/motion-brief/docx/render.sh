#!/bin/sh
# DOCX build for the C.D. Cal. motion (cacd), engine docx (docs/DOCX.md). Owns the .docx:
#   sh docx/render.sh <doc-dir> <sample.md, relative to the doc dir> <out.docx>
# 1. pandoc (markdown -> docx) on docx/reference.docx with docx/cacd-motion-brief.lua (cover, sections, tables, memorandum, signature);
# 2. the footer's two text lines are set from the sample's frontmatter (footer_title, case_number), which the
#    reference cannot know: the placeholders @FOOTER_TITLE@ and @FOOTER_CASE@ are replaced in word/footer1.xml;
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

# frontmatter values (the block between the first two '---' lines)
awk 'BEGIN { n = 0 } /^---[ \t]*$/ && n < 2 { n++; next } n == 1' "$SAMPLE" > "$W/fm.yaml"
FOOTER_TITLE=$(yq e '.footer_title' "$W/fm.yaml")
CASE_NO=$(yq e '.case_number' "$W/fm.yaml")
[ -n "$FOOTER_TITLE" ] && [ "$FOOTER_TITLE" != null ] || { echo "render.sh: the sample needs footer_title" >&2; exit 1; }
[ -n "$CASE_NO" ] && [ "$CASE_NO" != null ] || { echo "render.sh: the sample needs case_number" >&2; exit 1; }
xesc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
FT=$(xesc "$FOOTER_TITLE")
FC=$(xesc "Case No. $CASE_NO")

pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/cacd-motion-brief.lua" "$SAMPLE" -o "$W/stage.docx"
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/stage.docx"
for f in word/footer*.xml; do
  [ -f "$f" ] || continue
  sed -i -e "s|@FOOTER_TITLE@|$FT|" -e "s|@FOOTER_CASE@|$FC|" "$f"
  grep -q '@FOOTER' "$f" && { echo "render.sh: $f keeps a placeholder" >&2; exit 1; }
  xmllint --noout "$f"
done
for part in word/document.xml word/styles.xml; do xmllint --noout "$part"; done
rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find . -type f ! -name '[[]Content_Types[]].xml' | sed 's|^\./||' | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
