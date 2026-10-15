#!/bin/sh
# Owns the .docx of the txnd motion brief (docs/EVAL-LOOP.md, "Engines"): pandoc with reference.docx and
# txnd-motion-brief.lua, then the footer's relationship id is written in place of the placeholder RIDPAGE that the
# filter puts in the section breaks (pandoc numbers its relationships itself, so the id is read from the output).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# tools/render-docx.sh calls this, then converts the .docx with soffice (Gates 0 to 3 run on that PDF).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/txnd-motion-brief.lua" "$SAMPLE" -o "$T/raw.docx")
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/raw.docx")
RID=$(tr '>' '\n' < "$T/x/word/_rels/document.xml.rels" | grep 'footer1.xml' | sed 's/.* Id="\([^"]*\)".*/\1/')
[ -n "$RID" ] || {
  echo "render.sh: no footer1.xml relationship in the pandoc output" >&2
  exit 1
}
sed -i "s/RIDPAGE/$RID/g" "$T/x/word/document.xml"
rm -f "$OUT"
(cd "$T/x" && zip -X -q "$OUT" '[Content_Types].xml' && zip -X -q -r "$OUT" _rels docProps word)
echo "$OUT"
