#!/bin/sh
# DOCX engine for the W.D. Wash. adversary complaint: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc writes the body (motion-brief.lua) on reference.docx; then the bottom notation (footer_title, footer_counsel from
# the sample's frontmatter) is written into the footer's placeholders, so no case text lives in the template.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/motion-brief.lua" "$SAMPLE" -o "$W/raw.docx"
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/raw.docx"
FM="$COURT/$SAMPLE"
TITLE=$(yq --front-matter=extract '.footer_title // ""' "$FM" | tr 'a-z' 'A-Z')
C1=$(yq --front-matter=extract '.footer_counsel[0] // ""' "$FM")
C2=$(yq --front-matter=extract '.footer_counsel[1] // ""' "$FM")
ESC='s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g'
TITLE=$(printf '%s' "$TITLE" | sed -e "$ESC")
C1=$(printf '%s' "$C1" | sed -e "$ESC")
C2=$(printf '%s' "$C2" | sed -e "$ESC")
FOOTER_TITLE="$TITLE" FOOTER_C1="$C1" FOOTER_C2="$C2" perl -0777 -i -pe '
  s/\@FOOTER_TITLE\@/$ENV{FOOTER_TITLE}/g;
  s/\@FOOTER_COUNSEL_1\@/$ENV{FOOTER_C1}/g;
  s/\@FOOTER_COUNSEL_2\@/$ENV{FOOTER_C2}/g;
' word/footer1.xml
! grep -q '@FOOTER_' word/footer1.xml || { echo "render.sh: footer placeholders left unfilled" >&2; exit 1; }
xmllint --noout word/footer1.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" . -x '[Content_Types].xml'
echo "$OUT"
