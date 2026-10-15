#!/bin/sh
# Writes the complaint .docx for one sample: pandoc on reference.docx with docx/*.lua, then the numbering
# definitions that pandoc drops from numbering.xml. The styles keep their numPr (numId 9001 for the numbered
# allegations, 9002 for the prayer letters; see build-reference.sh), so the definitions are added back here.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D="$COURT/docx"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$W/out.docx")

mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/out.docx"
ABS='<w:abstractNum w:abstractNumId="9001"><w:multiLevelType w:val="singleLevel"/><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/><w:pStyle w:val="Allegation"/><w:suff w:val="tab"/><w:lvlText w:val="%1."/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="1280"/></w:tabs><w:ind w:left="0" w:firstLine="720"/></w:pPr></w:lvl></w:abstractNum><w:abstractNum w:abstractNumId="9002"><w:multiLevelType w:val="singleLevel"/><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="upperLetter"/><w:pStyle w:val="PrayerItem"/><w:suff w:val="tab"/><w:lvlText w:val="%1."/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="1296"/></w:tabs><w:ind w:left="1296" w:hanging="576"/></w:pPr></w:lvl></w:abstractNum>'
NUM='<w:num w:numId="9001"><w:abstractNumId w:val="9001"/></w:num><w:num w:numId="9002"><w:abstractNumId w:val="9002"/></w:num>'
# abstractNum elements must precede num elements
ABS=$ABS perl -0pi -e 's{(<w:num )}{$ENV{ABS}$1}' word/numbering.xml
NUM=$NUM perl -0pi -e 's{</w:numbering>}{$ENV{NUM}</w:numbering>}' word/numbering.xml
grep -q 'w:numId="9001"' word/numbering.xml || { echo "render.sh: numbering 9001 was not added" >&2; exit 1; }

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
