#!/bin/sh
# Builds docx/reference.docx: the styles and page setup of the msnb adversary-complaint typst template, as Word
# styles. EB Garamond 12 point; body double spaced (24 pt baseline, exact); headings centered bold, level 1 in caps
# capitals (level 1), bold (level 2), bold italic (level 3); footnotes 10 point; US Letter with 1 inch
# margins; page number centered in the footer. Run once (needs pandoc, unzip, zip); the result is committed.
# Usage: sh docx/make-reference.sh   (from the doc-type folder)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"
X="$W/x"
cat > "$X/word/styles.xml" <<STYLES
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles $NS>
<w:docDefaults>
<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
</w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="LetteredItem"><w:name w:val="Lettered Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:after="0"/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="360" w:after="240" w:line="480" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:pPr><w:spacing w:before="120" w:after="120" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteTextChar"><w:name w:val="Footnote Text Char"/><w:basedOn w:val="DefaultParagraphFont"/><w:link w:val="FootnoteText"/><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:basedOn w:val="DefaultParagraphFont"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:basedOn w:val="DefaultParagraphFont"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:semiHidden/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/></w:style>
<w:style w:type="character" w:customStyle="1" w:styleId="VerbatimChar"><w:name w:val="Verbatim Char"/><w:basedOn w:val="DefaultParagraphFont"/></w:style>
</w:styles>
STYLES
cat > "$X/word/footer1.xml" <<FOOTER
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
FOOTER
cat > "$X/word/document.xml" <<DOC
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document $NS><w:body><w:p/><w:sectPr><w:footerReference w:type="default" r:id="rIdMsnbFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:body></w:document>
DOC
# the footer part: relationship and content type
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdMsnbFooter1" Target="footer1.xml" /></Relationships>#' "$X/word/_rels/document.xml.rels"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$X/[Content_Types].xml"
rm -f "$D/reference.docx"
(cd "$X" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
