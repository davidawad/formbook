#!/bin/sh
# Builds docx/reference.docx: the Word styles, page setup and page-number footer of the mowb docx engine
# (see ../README.md, "Engines"). Run from anywhere: sh docx/make-reference.sh
# The base package is pandoc's default reference.docx; its styles and section properties are replaced here.
# Needs pandoc, zip, unzip and xmllint. This file is identical in both doc-type folders except KIND.
set -eu
KIND=memo   # complaint | memo
case $KIND in
  complaint)
    # Typst: double spacing, one line pitch (24 pt) between lines and 1.2 em (15.6 pt) between paragraphs.
    BODY_SP='<w:spacing w:before="0" w:after="312" w:line="480" w:lineRule="exact"/>'
    H1_JC=center
    H1_BEFORE=480
    ;;
  memo)
    # Typst: single spacing within a paragraph, one blank line between paragraphs.
    BODY_SP='<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="auto"/>'
    H1_JC=left
    H1_BEFORE=240
    ;;
  *)
    echo "make-reference.sh: unknown KIND $KIND" >&2
    exit 2
    ;;
esac
H1_AFTER=312
[ "$KIND" = memo ] && H1_AFTER=240

D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/base.docx"
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
X=$W/x

# ---- styles: names are the Word built-in names (pandoc maps its elements to them); custom styles are
# used by mowb.lua through pandoc's custom-style divs and by the raw OOXML paragraphs of the caption.
cat > "$X/word/styles.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>
  <w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
  <w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$BODY_SP</w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="$H1_BEFORE" w:after="$H1_AFTER" w:line="240" w:lineRule="auto"/><w:jc w:val="$H1_JC"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:caps/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1080"/></w:tabs><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:i/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="DocumentTitle"><w:name w:val="Document Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="IndentedParagraph"><w:name w:val="Indented Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1800"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="LetteredItem"><w:name w:val="Lettered Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4752"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CertificateHeading"><w:name w:val="Certificate Heading"/><w:basedOn w:val="Normal"/><w:next w:val="IndentedParagraph"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="$H1_BEFORE" w:after="$H1_AFTER" w:line="240" w:lineRule="auto"/><w:jc w:val="$H1_JC"/></w:pPr><w:rPr><w:b/><w:caps/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:rPr><w:color w:val="000000"/><w:u w:val="single"/></w:rPr></w:style>
</w:styles>
EOF

# ---- page setup: US Letter, 1 inch on every side (typst: page-margin 1in); footer with the page number, arabic from 1
cat > "$X/word/footer1.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:fldSimple w:instr=" PAGE "><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:t>1</w:t></w:r></w:fldSimple></w:p></w:ftr>
EOF
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdMowbFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
grep -q 'xmlns:r=' "$X/word/document.xml" || {
  echo "make-reference.sh: pandoc's document.xml has no xmlns:r declaration" >&2
  exit 1
}
sed -e '/<w:sectPr>/,/<\/w:sectPr>/d' -e "s|</w:body>|$SECT</w:body>|" "$X/word/document.xml" > "$W/document.xml"
mv "$W/document.xml" "$X/word/document.xml"
sed -e 's|</Relationships>|<Relationship Id="rIdMowbFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>|' "$X/word/_rels/document.xml.rels" > "$W/rels"
mv "$W/rels" "$X/word/_rels/document.xml.rels"
sed -e 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' "$X/[Content_Types].xml" > "$W/ct"
mv "$W/ct" "$X/[Content_Types].xml"

for part in "$X/word/styles.xml" "$X/word/document.xml" "$X/word/footer1.xml" "$X/word/_rels/document.xml.rels" "$X/[Content_Types].xml"; do
  xmllint --noout "$part" || {
    echo "make-reference.sh: ${part#$X/} is not well-formed XML" >&2
    exit 1
  }
done

rm -f "$D/reference.docx"
(cd "$X" && zip -q -X -D -r "$D/reference.docx" .)
unzip -tq "$D/reference.docx" > /dev/null
echo "$D/reference.docx"
