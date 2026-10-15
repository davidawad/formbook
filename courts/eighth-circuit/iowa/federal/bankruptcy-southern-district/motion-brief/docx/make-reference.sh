#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: EB Garamond 12 pt, exact 24 pt double spacing for the
# body (measured on the typst render, OUTPUT-<id>.pdf: 24 pt pitch), single spacing for the caption, the signature
# block and the table, 1 inch margins on letter paper, and a centered page number in the footer.
# Run once (sh docx/make-reference.sh); the output is committed. Needs pandoc, zip and unzip.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=$D/reference.docx
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/base.docx"
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
X="$W/x"
W_NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
# ---- styles: every style pandoc and the filter refer to ----
cat > "$X/word/styles.xml" <<STYLES
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles $W_NS>
<w:docDefaults>
<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
</w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/></w:pPr><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="numbering" w:default="1" w:styleId="NoList"><w:name w:val="No List"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="120" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1080" w:right="1080"/><w:jc w:val="both"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:basedOn w:val="DefaultParagraphFont"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1080"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="IndentedParagraph"><w:name w:val="Indented Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerItem"><w:name w:val="Prayer Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleSpaced"><w:name w:val="Single Spaced"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtName"><w:name w:val="Court Name"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="59"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:tblPr><w:tblInd w:w="720" w:type="dxa"/><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tblBorders><w:tblCellMar><w:top w:w="29" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="29" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
</w:styles>
STYLES
# ---- section: letter, 1 inch margins, footer with the page number, centered ----
cat > "$X/word/document.xml" <<DOC
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document $W_NS>
<w:body>
<w:p/>
<w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>
</w:body>
</w:document>
DOC
cat > "$X/word/footer1.xml" <<FOOTER
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $W_NS>
<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>
</w:ftr>
FOOTER
# ---- relationship and content type for the footer ----
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml" /></Relationships>|' "$X/word/_rels/document.xml.rels"
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' "$X/[Content_Types].xml"
# ---- zip: [Content_Types].xml first ----
rm -f "$OUT"
(cd "$X" && zip -X -q "$OUT" '[Content_Types].xml' && zip -X -q -r "$OUT" . -x '[Content_Types].xml')
echo "$OUT"
