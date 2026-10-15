#!/bin/sh
# DOCX engine for calsuperct-sandiego complaint (docs/DOCX.md). tools/render-docx.sh calls this:
#   sh docx/render.sh <doctype-dir> <sample.md, relative to it> <out.docx>
# 1. pandoc: the markdown body on docx/reference.docx, with docx/calsuperct-sandiego-motion-brief.lua
#    (first page, caption, signature block from the frontmatter).
# 2. the footer title (frontmatter footer_title) replaces @@FOOTER_TITLE@@ in the footer part.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D="$COURT/docx"
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

(cd "$COURT" && pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" \
  --lua-filter="$D/calsuperct-sandiego-motion-brief.lua" \
  "$SAMPLE" -o "$W/body.docx") || exit 1

# footer title from the frontmatter (between the first two '---' lines), XML-escaped
TITLE=$(awk '
  /^---[ \t]*$/ { n++; if (n == 2) exit; next }
  n == 1 && /^footer_title:/ { sub(/^footer_title:[ \t]*/, ""); print; exit }
' "$COURT/$SAMPLE")
TITLE=$(printf '%s' "$TITLE" | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'\$/\1/")
[ -n "$TITLE" ] || {
  echo "render.sh: no footer_title in $SAMPLE" >&2
  exit 1
}
ESC=$(printf '%s' "$TITLE" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[\\&|]/\\&/g')

mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/body.docx"
grep -l '@@FOOTER_TITLE@@' word/footer*.xml > /dev/null || {
  echo "render.sh: no footer part carries the title placeholder" >&2
  exit 1
}
sed -i "s|@@FOOTER_TITLE@@|$ESC|" word/footer*.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" . -x '[Content_Types].xml'
