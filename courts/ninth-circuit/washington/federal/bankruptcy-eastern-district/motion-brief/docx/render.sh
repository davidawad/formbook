#!/bin/sh
# DOCX engine for the E.D. Wash. bankruptcy court (WAEB) pleadings: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Runs pandoc with reference.docx and the doc type's Lua filter, then writes the footer title from the frontmatter
# (footer_title, default DEFAULT_FOOTER) into the footer.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
DEFAULT_FOOTER=${DEFAULT_FOOTER:-MEMORANDUM}
LUA=${LUA:-$D/motion-brief.lua}
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
# pandoc reads a footnote definition or a heading on the line after a paragraph (the typst contract has no blank line
# there) as continuation text: put a blank line before them. A "~ " paragraph is a definition-list marker to pandoc: escape it
# (the Lua filter then sees a Str "~")
awk 'prev != "" && prev !~ /^- / && ($0 ~ /^\[\^[^]]+\]:/ || $0 ~ /^#(#)? / || $0 ~ /^- /) { print "" } $0 ~ /^~ / { sub(/^~ /, "\\~ ") } { print; prev = $0 }' "$COURT/$SAMPLE" > "$W/sample.md"
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$LUA" "$W/sample.md" -o "$W/raw.docx"
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/raw.docx"
TITLE=$(yq --front-matter=extract '.footer_title // ""' "$COURT/$SAMPLE")
[ -n "$TITLE" ] || TITLE=$DEFAULT_FOOTER
TITLE=$(printf '%s' "$TITLE" | tr 'a-z' 'A-Z' | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
sed -i "s|@FOOTER_TITLE@|$TITLE|" word/footer1.xml
xmllint --noout word/footer1.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
