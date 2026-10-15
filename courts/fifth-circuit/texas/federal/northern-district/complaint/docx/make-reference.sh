#!/bin/sh
# Builds docx/reference.docx: pandoc's default Word package with the court's styles (styles.xml, beside this script),
# letter paper, 1 in margins, and a centered page-number footer on every page (see ../typst/txnd-complaint.typ).
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, unzip, zip and xmllint on PATH)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/w"
(cd "$T/w" && unzip -q "$T/default.docx")
cp "$D/styles.xml" "$T/w/word/styles.xml"
# footer: the PAGE field, cached result 1 (Word and LibreOffice update it on every page)
cat > "$T/w/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$T/w/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$T/w/[Content_Types].xml"
# the body section: footer reference, footnote numbering, letter page, 1 in margins
perl -0pi -e 's{<w:sectPr>\s*<w:footnotePr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /></w:sectPr>}s' "$T/w/word/document.xml"
for f in "$T/w/word/styles.xml" "$T/w/word/document.xml" "$T/w/word/footer1.xml" "$T/w/word/_rels/document.xml.rels" "$T/w/[Content_Types].xml"; do
  xmllint --noout "$f"
done
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
rm -f "$OUT"
(cd "$T/w" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
