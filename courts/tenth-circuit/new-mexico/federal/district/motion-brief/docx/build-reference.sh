#!/bin/sh
# Builds docx/reference.docx for the D.N.M. motion (with its supporting brief) from pandoc's default reference (see
# ../typst/nmd-motion-brief.typ): EB Garamond 12 pt; 24 pt exact (double) line pitch for the body, first-line indent
# 0.5 in; single lines at exact 13.8 pt for the caption, signature, certificate and lists of addresses; level 1
# headings centered in capitals; level 2 and 3 headings bold, single spaced, hanging 0.5 in; letter page; top margin
# 1.5 in, others 1 in; centered page number 0.45 in from the bottom edge.
# The styles are written here, in full (pandoc's default styles use theme fonts). Custom styles (NMD ...) are used by
# nmd.lua; the cover, caption, signature block and certificate of service are built there.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

cat > word/styles.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults>
<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
</w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:tblPr><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>

<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:basedOn w:val="DefaultParagraphFont"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>

<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDCourt"><w:name w:val="NMD Court"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="480" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDSingle"><w:name w:val="NMD Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDSingleGap"><w:name w:val="NMD Single Gap"/><w:basedOn w:val="NMDSingle"/><w:qFormat/><w:pPr><w:spacing w:before="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDCaptionIndent"><w:name w:val="NMD Caption Indent"/><w:basedOn w:val="NMDSingle"/><w:qFormat/><w:pPr><w:ind w:left="1728" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDCaseNo"><w:name w:val="NMD Case No"/><w:basedOn w:val="NMDSingle"/><w:qFormat/><w:pPr><w:ind w:left="288" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDSig"><w:name w:val="NMD Sig"/><w:basedOn w:val="NMDSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDSigGap"><w:name w:val="NMD Sig Gap"/><w:basedOn w:val="NMDSig"/><w:qFormat/><w:pPr><w:spacing w:before="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDSigStart"><w:name w:val="NMD Sig Start"/><w:basedOn w:val="NMDSig"/><w:qFormat/><w:pPr><w:spacing w:before="480"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDCertSigned"><w:name w:val="NMD Cert Signed"/><w:basedOn w:val="NMDSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480"/><w:ind w:left="4752" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDCertSignedNext"><w:name w:val="NMD Cert Signed Next"/><w:basedOn w:val="NMDSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4752" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDTitle"><w:name w:val="NMD Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="240" w:line="480" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDList"><w:name w:val="NMD List"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:ind w:left="1296" w:hanging="576" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NMDListLast"><w:name w:val="NMD List Last"/><w:basedOn w:val="NMDList"/><w:qFormat/><w:pPr><w:spacing w:after="160"/></w:pPr></w:style>
</w:styles>
XML

# footer: centered PAGE field, 12 pt (the body size), with the cached result 1
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML

# body: an empty document whose only content is the section (letter, margins, footer at 0.45 in)
cat > word/document.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="648" w:gutter="0"/></w:sectPr></w:body></w:document>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X -r "$OUT" '[Content_Types].xml' _rels docProps word
echo "$OUT"
