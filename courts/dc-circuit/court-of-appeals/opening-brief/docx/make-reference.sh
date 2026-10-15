#!/bin/sh
# Build docx/reference.docx: pandoc's default reference with the court's page setup and styles (run once; the
# output is checked in). Needs pandoc, unzip, zip, perl. Usage: sh docx/make-reference.sh <court-dir>/docx
# TeX Gyre Schola 14 pt, body lines exactly 24 pt (double-spaced), first-line indent 0.5 in, headings in black,
# 1 in margins on letter paper, page number in the footer.
set -eu
D=$(cd "$1" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && unzip -q ref.docx -d x && cd x
perl -0pi -e 's#<w:rFonts[^>]*/>#<w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" w:eastAsia="TeX Gyre Schola" w:cs="TeX Gyre Schola"/>#g; s#<w:sz w:val="\d+"/>#<w:sz w:val="28"/>#g; s#<w:szCs w:val="\d+"/>#<w:szCs w:val="28"/>#g; s#<w:color w:val="[0-9A-Fa-f]{6}"/>#<w:color w:val="000000"/>#g' word/styles.xml
perl -0pi -e 's#(<w:style [^>]*w:styleId="(BodyText|FirstParagraph)".*?<w:pPr>)#$1<w:ind w:firstLine="720"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>#gs' word/styles.xml
perl -0pi -e 's#(<w:style [^>]*w:styleId="FootnoteText".*?<w:pPr>)#$1<w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/>#gs' word/styles.xml
perl -0pi -e 's#(<w:sectPr[^>]*>)#$1<w:footerReference w:type="default" r:id="rIdFooterCourt"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>#' word/document.xml
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's#</Relationships>#<Relationship Id="rIdFooterCourt" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>#' word/_rels/document.xml.rels
perl -0pi -e 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>#' '[Content_Types].xml'
rm -f "$D/reference.docx"
zip -q -X -r "$D/reference.docx" '[Content_Types].xml' _rels docProps word
echo "$D/reference.docx"
