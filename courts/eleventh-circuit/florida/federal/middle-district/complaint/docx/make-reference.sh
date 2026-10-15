#!/bin/sh
# Build a pandoc reference.docx for flmd pleadings (M.D. Fla. Local Rule 1.08(b): Times New Roman, 14-point main text).
# Usage: sh make-reference.sh <out.docx> complaint|motion
# Starts from pandoc's own reference (for its package parts), replaces styles.xml and the body's section
# (Letter, 1-inch margins, no number on page one, bottom-center PAGE field from page two), and writes the result.
# Re-run to rebuild; the court's typst template is the reference for the layout (see ../README.md, "Engines").
set -eu
OUT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
KIND=$2
case $KIND in
  complaint) H3_STYLE='<w:b/><w:i/>' ;;   # complaint typst: level 3 bold italic
  motion) H3_STYLE='<w:b/>' ;;            # motion typst: level 3 bold, level 4 bold italic
  *)
    echo "make-reference.sh: kind must be complaint or motion" >&2
    exit 2
    ;;
esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/default.docx"
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/default.docx")
X=$W/x

# --- styles.xml: Times New Roman 14 pt, double-spaced (Word's "double", line 480 auto); single where the rules say so.
cat > "$X/word/styles.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/>
    <w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr>
    <w:rPr><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
  <w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
  <w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
  <w:style w:type="numbering" w:default="1" w:styleId="NoList"><w:name w:val="No List"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/></w:style>

  <w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:line="240" w:lineRule="auto"/></w:pPr></w:style>

  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$H3_STYLE</w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:i/></w:rPr></w:style>

  <w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>
    <w:pPr><w:spacing w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/>
    <w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:basedOn w:val="DefaultParagraphFont"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:basedOn w:val="DefaultParagraphFont"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>

  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverTitle"><w:name w:val="Cover Title"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:keepNext/><w:spacing w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="Caption Line"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:spacing w:line="240" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionGap"><w:name w:val="Caption Gap"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedPara"><w:name w:val="Numbered Para"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="IndentedPara"><w:name w:val="Indented Para"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="UnindentedPara"><w:name w:val="Unindented Para"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="LetteredItem"><w:name w:val="Lettered Item"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureLine"><w:name w:val="Signature Line"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/><w:spacing w:line="240" w:lineRule="auto"/><w:ind w:left="4320"/><w:jc w:val="left"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepUnindented"><w:name w:val="Keep Unindented"/><w:basedOn w:val="UnindentedPara"/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepIndented"><w:name w:val="Keep Indented"/><w:basedOn w:val="IndentedPara"/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureOpen"><w:name w:val="Signature Open"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:keepNext/><w:keepLines/><w:spacing w:line="240" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepGap"><w:name w:val="Keep Gap"/><w:basedOn w:val="Normal"/><w:qFormat/>
    <w:pPr><w:keepNext/></w:pPr></w:style>
</w:styles>
EOF

# --- document.xml: pandoc takes only the section properties from the reference body.
cat > "$X/word/document.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:titlePg/></w:sectPr></w:body></w:document>
EOF

# --- footer: PAGE field, bottom center; the first page has no footer (titlePg, no first-page footer part).
cat > "$X/word/footer1.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
EOF
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /></Relationships>#' "$X/word/_rels/document.xml.rels"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$X/[Content_Types].xml"

for part in "$X"/word/*.xml "$X"/word/_rels/*.rels "$X/[Content_Types].xml"; do
  xmllint --noout "$part"
done
rm -f "$OUT"
(cd "$X" && zip -q -X -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
