#!/bin/sh
# DOCX engine for the oked motion to dismiss with brief in support (docs/DOCX.md, "Engines"): pandoc with
# reference.docx and motion-brief.lua, then the parts pandoc does not copy from the reference: the letter page
# setup with 1 in margins, and the centered 12 pt page-number footer. Edited with ziptool (unzip and zip are not
# installed on the build box).
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
Z=$W/out.docx
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/motion-brief.lua" "$SAMPLE" -o "$Z")

entry() { ziptool "$Z" name_locate "$1" 0 2>/dev/null | awk '/found at index/ { print $NF }'; }
get() { ziptool "$Z" cat "$(entry "$1")" > "$2"; }
put() {
  i=$(entry "$1")
  if [ -n "$i" ]; then
    ziptool "$Z" replace_file_contents "$i" "$(cat "$2")" > /dev/null
  else
    ziptool "$Z" add "$1" "$(cat "$2")" > /dev/null
  fi
}

# footer part: a centered PAGE field at 12 pt (cached result 1; Word and LibreOffice update it)
cat > "$W/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
put word/footer1.xml "$W/footer1.xml"

# section: letter, 1 in margins, the footer (footnotePr kept from pandoc's sectPr)
get word/document.xml "$W/document.xml"
export NEWSECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{$ENV{NEWSECT}}s' "$W/document.xml"
put word/document.xml "$W/document.xml"

get word/_rels/document.xml.rels "$W/rels.xml"
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml"/></Relationships>}' "$W/rels.xml"
put word/_rels/document.xml.rels "$W/rels.xml"

get '[Content_Types].xml' "$W/ct.xml"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$W/ct.xml"
put '[Content_Types].xml' "$W/ct.xml"

# every XML part must be well formed (the same check tools/render-docx.sh makes)
for p in word/document.xml word/styles.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml' word/footnotes.xml; do
  get "$p" "$W/check.xml"
  xmllint --noout "$W/check.xml"
done

cp "$Z" "$OUT"
