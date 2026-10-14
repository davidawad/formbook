#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: EB Garamond 14 pt, double spacing (exact
# 31.5 pt), 1 inch margins, the styles the filter uses, and three footers (empty, roman/arabic page number,
# "Add-N"). Run once (sh docx/make-reference.sh); the output is committed. Same content in every doc type.
set -eu
MODE=${1:?usage: make-reference.sh addendum|none}
FTR=rIdFtr1
[ "$MODE" = addendum ] && FTR=rIdFtr3
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/base.docx"
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
X="$W/x/word"
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
SECT='<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
# ---- styles ----
cat > "$X/styles.xml" <<STYLES
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles $NS>
<w:docDefaults>
<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="630" w:lineRule="exact"/></w:pPr></w:pPrDefault>
</w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:semiHidden/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="420" w:after="220" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:caps/><w:sz w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="180" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="160" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:hanging="720"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="160" w:line="240" w:lineRule="auto"/><w:ind w:left="2160" w:hanging="720"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:i/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="160" w:line="240" w:lineRule="auto"/><w:ind w:left="2880" w:hanging="720"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="120" w:line="320" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="200" w:line="320" w:lineRule="exact"/><w:ind w:left="720" w:right="720"/></w:pPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverLine"><w:name w:val="Cover Line"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="320" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleSpaced"><w:name w:val="Single Spaced"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="200" w:line="320" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="320" w:lineRule="exact"/><w:ind w:left="4320"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ContentsLine"><w:name w:val="Contents Line"/><w:basedOn w:val="Normal"/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:after="160" w:line="320" w:lineRule="exact"/></w:pPr></w:style>
</w:styles>
STYLES
# ---- footers: 1 = roman/arabic page number, 2 = empty (cover), 3 = "Add-N" ----
footer() { # $1 file, $2 paragraph content (runs)
  cat > "$X/$1" <<FOOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p><w:pPr><w:spacing w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr>$2</w:p></w:ftr>
FOOT
}
PAGEFIELD='<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
footer footer1.xml "$PAGEFIELD"
footer footer2.xml ""
footer footer3.xml "<w:r><w:t xml:space=\"preserve\">Add-</w:t></w:r>$PAGEFIELD"
# ---- relationships and content types for the footers ----
sed -i 's#</Relationships>#<Relationship Id="rIdFtr1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/><Relationship Id="rIdFtr2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer2.xml"/><Relationship Id="rIdFtr3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer3.xml"/></Relationships>#' "$X/_rels/document.xml.rels"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer3.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>#' "$X/../[Content_Types].xml"
# ---- the reference body: an empty document whose final section is the addendum's (Add-N, from 1) ----
cat > "$X/document.xml" <<DOC
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document $NS><w:body><w:p/><w:sectPr><w:footerReference w:type="default" r:id="$FTR"/><w:pgNumType w:fmt="decimal" w:start="1"/>$SECT</w:sectPr></w:body></w:document>
DOC
(cd "$W/x" && zip -q -X -r "$W/reference.docx" '[Content_Types].xml' _rels docProps word customXml 2>/dev/null || (cd "$W/x" && zip -q -X -r "$W/reference.docx" .))
cp "$W/reference.docx" "$D/reference.docx"
echo "$D/reference.docx"
