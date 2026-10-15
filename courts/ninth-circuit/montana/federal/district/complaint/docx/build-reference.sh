#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: EB Garamond 14 pt (no face is named by the
# court; the vendored face is used, see README.md), exact 32 pt (double) line spacing, 1 in margins,
# Letter, a centred PAGE number in the footer. The styles are in reference-styles.xml (this folder).
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, unzip, zip, xmllint, perl on PATH)
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q ../ref.docx)
P="$W/pkg"
# styles: defaults, body, headings, custom styles (merge: a style with the same id is replaced)
perl "$HERE/merge-styles.pl" "$P/word/styles.xml" "$HERE/reference-styles.xml"
# body section: Letter, 1 in margins, footer with the page number; pgNumType decimal from 1 (the memorandum)
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdMtdFooter1"/><w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' "$P/word/document.xml"
grep -q 'xmlns:r=' "$P/word/document.xml" || { echo "build-reference.sh: document has no r namespace" >&2; exit 1; }
cat > "$P/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdMtdFooter1" Target="footer1.xml"/></Relationships>}' "$P/word/_rels/document.xml.rels"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$P/[Content_Types].xml"
for part in "$P/word/styles.xml" "$P/word/document.xml" "$P/word/footer1.xml" "$P/word/_rels/document.xml.rels" "$P/[Content_Types].xml"; do xmllint --noout "$part"; done
rm -f "$OUT"
(cd "$P" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" _rels docProps word)
echo "$OUT"
