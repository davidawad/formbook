#!/bin/sh
# DOCX engine for the W.D. Wash. motion to dismiss with memorandum: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc reads the sample as CommonMark (commonmark_x+smart), as cmarker does in the typst template: a Westlaw
# star page "*2" stays literal, not emphasis. pandoc writes the body on reference.docx with the Lua filter; this script
# then writes the bottom notation (typst footer(): title and case number at left with the page number; the firm
# block at right) from the sample frontmatter. Called by tools/render-docx.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
pandoc --from commonmark_x+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/motion-brief.lua" "$SAMPLE" -o "$W/raw.docx"
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/raw.docx"

esc() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
FRONT="$COURT/$SAMPLE"
TITLE=$(esc "$(yq --front-matter=extract '.footer_title // ""' "$FRONT" | tr 'a-z' 'A-Z')")
CASE=$(esc "$(yq --front-matter=extract '.case_number // ""' "$FRONT")")
FIRM=$(yq --front-matter=extract -o=json '.footer_firm // []' "$FRONT" | jq -r '.[]')

NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
RPR10='<w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr>'
{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  printf '<w:ftr %s>' "$NS"
  printf '%s' '<w:tbl><w:tblPr><w:tblW w:w="8640" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr><w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="3600"/></w:tblGrid><w:tr>'
  printf '%s' '<w:tc><w:tcPr><w:tcW w:w="5040" w:type="dxa"/></w:tcPr>'
  printf '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr><w:r>%s<w:t xml:space="preserve">%s</w:t></w:r></w:p>' "$RPR10" "$TITLE"
  printf '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr><w:r>%s<w:t xml:space="preserve">(Case No. %s) &#8211; </w:t></w:r><w:r>%s<w:fldChar w:fldCharType="begin"/></w:r><w:r>%s<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>%s<w:fldChar w:fldCharType="separate"/></w:r><w:r>%s<w:t>1</w:t></w:r><w:r>%s<w:fldChar w:fldCharType="end"/></w:r></w:p>' "$RPR10" "$CASE" "$RPR10" "$RPR10" "$RPR10" "$RPR10" "$RPR10"
  printf '%s' '</w:tc>'
  printf '%s' '<w:tc><w:tcPr><w:tcW w:w="3600" w:type="dxa"/></w:tcPr>'
  printf '%s\n' "$FIRM" | while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="210" w:lineRule="exact"/><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:sz w:val="18"/><w:szCs w:val="18"/></w:rPr><w:t xml:space="preserve">%s</w:t></w:r></w:p>' "$(esc "$line")"
  done
  [ -n "$FIRM" ] || printf '%s' '<w:p/>'
  printf '%s' '</w:tc></w:tr></w:tbl>'
  printf '%s' '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>'
  printf '%s\n' '</w:ftr>'
} > word/footer1.xml
xmllint --noout word/footer1.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
