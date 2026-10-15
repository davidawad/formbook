#!/bin/sh
# DOCX engine for the D. Conn. adversary complaint: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# The docket line (adv_number, judge) of the sample's frontmatter goes into the header of a copy of reference.docx (the
# reference itself stays generic); pandoc then writes the body with ctb-adversary-complaint.lua. Called by tools/render-docx.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
awk 'NR == 1 && /^---[ \t]*$/ { f = 1; next } f && /^---[ \t]*$/ { exit } f' "$COURT/$SAMPLE" > "$W/meta.yaml"
esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/[|\\]/\\&/g'; }
ADV=$(esc "$(yq -r '.adv_number' "$W/meta.yaml")")
JUDGE=$(esc "$(yq -r '.judge' "$W/meta.yaml")")
mkdir "$W/ref" && (cd "$W/ref" && unzip -q "$D/reference.docx")
sed -i -e "s|{{ADV_NUMBER}}|$ADV|" -e "s|{{JUDGE}}|$JUDGE|" "$W/ref/word/header1.xml"
(cd "$W/ref" && zip -q -X "$W/ref.docx" '[Content_Types].xml' && zip -q -X -r "$W/ref.docx" _rels docProps word)
cd "$COURT"
pandoc --from markdown+smart --to docx --reference-doc="$W/ref.docx" --lua-filter="$D/ctb-adversary-complaint.lua" "$SAMPLE" -o "$W/out.docx"
rm -f "$OUT"
cp "$W/out.docx" "$OUT"
echo "$OUT"
