#!/bin/sh
# Builds docx/reference.docx for the nmid motion with memorandum (D.N.M.I. LR 5.2; the layout of typst/nmid-motion-brief.typ).
# Letter, 1.5 in top, 1 in bottom (25 lines at 24 pt), 1 in left, 0.5 in right; EB Garamond 12 pt; double
# spacing (exact 24 pt); numbered lines 1-25 in a header frame in the left margin (not w:lnNumType, so the
# numbers stay fixed whatever the content); pleading rules as page borders; footer with the page number and the
# case caption, whose text is substituted per sample by docx/render.sh (placeholders {{FOOTER_TITLE}}, {{CASE_NO}}).
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
cat > word/styles.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr>${FONT}<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>${FONT}<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Item"><w:name w:val="Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ItemKeep"><w:name w:val="Item Keep"/><w:basedOn w:val="Item"/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="atLeast"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/><w:keepNext/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2160"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="2160" w:hanging="720"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2880"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="2880" w:hanging="720"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="276" w:lineRule="atLeast"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Header"><w:name w:val="header"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="LineNumber"><w:name w:val="Line Number"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>
</w:styles>
XML
# header: the line numbers 1-25 in a text box fixed to the page, in the left margin, one exact 24 pt line each
# (box top 1.5 in = the top margin; box height 25 x 24 pt). A VML text box, as in a watermark, which Word and
# LibreOffice both place absolutely; the box does not take part in the text flow.
{
  cat <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"><w:p><w:pPr><w:pStyle w:val="Header"/></w:pPr><w:r><w:pict><v:shapetype id="_x0000_t202" coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/></v:shapetype><v:shape id="LineNumbers" o:spid="_x0000_s1025" type="#_x0000_t202" filled="f" stroked="f" style="position:absolute;margin-left:14.4pt;margin-top:108pt;width:36pt;height:600pt;z-index:-251657216;mso-position-horizontal-relative:page;mso-position-vertical-relative:page"><v:textbox inset="0,0,0,0"><w:txbxContent>
XML
  i=1
  while [ "$i" -le 25 ]; do
    printf '<w:p><w:pPr><w:pStyle w:val="LineNumber"/></w:pPr><w:r><w:t>%s</w:t></w:r></w:p>\n' "$i"
    i=$((i + 1))
  done
  echo '</w:txbxContent></v:textbox></v:shape></w:pict></w:r></w:p></w:hdr>'
} > word/header1.xml
# footer: page number ("-N-") centred, then the title left and the case number right (placeholders)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Footer"/><w:tabs><w:tab w:val="right" w:pos="10080"/></w:tabs><w:spacing w:before="60"/></w:pPr><w:r><w:t>{{FOOTER_TITLE}}</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>CASE NO. {{CASE_NO}}</w:t></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /></Types>|' '[Content_Types].xml'
# body section: letter; 1.5 in top, 1 in bottom (25 x 24 pt lines), 1 in left, 0.5 in right; pleading rules
SECT='<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="720" w:bottom="1680" w:left="1440" w:header="720" w:footer="504" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="6" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="6" w:color="000000"/></w:pgBorders></w:sectPr>'
SECT="$SECT" perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>\s*</w:body>}{$ENV{SECT}</w:body>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/header1.xml; do xmllint --noout "$part"; done
cd "$W/pkg" && rm -f "$OUT" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
