#!/bin/sh
# Builds docx/reference.docx: pandoc's default reference with the Second Circuit page and type setup
# (typst/ca2-*.typ; rules in ../README.md): letter paper, 1-inch margins, EB Garamond 14 point, double
# spacing (31.4 pt, exact) for text, single spacing (19.9 pt, exact) for footnotes, block quotations,
# headings and the cover, a centered page number in the footer, and a blank footer for the cover.
# Run from anywhere; needs pandoc, unzip, zip and xmllint. The same file serves every doc type of the court.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/ref.docx")
X="$W/x"
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
cat > "$X/word/styles.xml" <<STYLES
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles $NS>
<w:docDefaults>
 <w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault>
 <w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
</w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="0" w:line="628" w:lineRule="exact"/></w:pPr><w:rPr><w:color w:val="000000"/><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="252" w:line="398" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="300" w:after="220" w:line="398" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:caps/><w:sz w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="180" w:line="398" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="220" w:after="160" w:line="398" w:lineRule="exact"/><w:ind w:left="2160" w:hanging="720"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="140" w:line="398" w:lineRule="exact"/><w:ind w:left="2880" w:hanging="720"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:i/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="140" w:line="398" w:lineRule="exact"/><w:ind w:left="3600" w:hanging="720"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/><w:i/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="100" w:line="398" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="VerbatimChar"><w:name w:val="Verbatim Char"/><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenterSingle"><w:name w:val="Center Single"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="398" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleLeft"><w:name w:val="Single Left"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="398" w:lineRule="exact"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="HalfBlock"><w:name w:val="Half Block"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="398" w:lineRule="exact"/><w:ind w:left="4680"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertText"><w:name w:val="Cert Text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="240" w:line="398" w:lineRule="exact"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TocEntry"><w:name w:val="Toc Entry"/><w:basedOn w:val="Normal"/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" w:line="398" w:lineRule="exact"/><w:ind w:left="0" w:hanging="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ToaGroup"><w:name w:val="Toa Group"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="280" w:after="120" w:line="398" w:lineRule="exact"/><w:jc w:val="left"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ToaEntry"><w:name w:val="Toa Entry"/><w:basedOn w:val="Normal"/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="160" w:after="0" w:line="398" w:lineRule="exact"/><w:ind w:left="504" w:hanging="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ToaName"><w:name w:val="Toa Name"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="160" w:after="0" w:line="398" w:lineRule="exact"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PointHeading"><w:name w:val="Point Heading"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="200" w:line="398" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:smallCaps/></w:rPr></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:semiHidden/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
</w:styles>
STYLES
for n in 1 2; do
  if [ "$n" = 1 ]; then BODY='<w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  else BODY='<w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr></w:p>'; fi
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' "<w:ftr $NS>$BODY</w:ftr>" > "$X/word/footer$n.xml"
done
# footer1: page number (the body sections); footer2: blank (the cover)
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter2" Target="footer2.xml" /></Relationships>|' "$X/word/_rels/document.xml.rels"
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' "$X/[Content_Types].xml"
# the final section (the body and certificates): page size, margins, decimal numbering from 1
sed -i 's|<w:sectPr>|<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/>|' "$X/word/document.xml"
grep -q 'rIdFooter1' "$X/word/document.xml" || { echo "make-reference.sh: sectPr not found" >&2; exit 1; }
for part in $(cd "$X" && find . -name '*.xml' -o -name '*.rels'); do
  xmllint --noout "$X/$part" || { echo "make-reference.sh: $part is not well-formed" >&2; exit 1; }
done
rm -f "$D/reference.docx"
(cd "$X" && zip -q -X "$D/reference.docx" '[Content_Types].xml' && zip -q -X -r "$D/reference.docx" . -x '[Content_Types].xml')
echo "$D/reference.docx"
