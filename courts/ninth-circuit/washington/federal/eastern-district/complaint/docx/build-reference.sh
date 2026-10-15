#!/bin/sh
# Builds docx/reference.docx for the E.D. Wash. pleading (docs/DOCX.md). Starts from pandoc's default reference and
# replaces its styles with the pleading-paper styles of the typst template (waed-complaint.typ / waed-motion-brief.typ):
# EB Garamond 14 pt, exact 640-twip (32 pt) double-spaced grid, 320-twip (16 pt) single lines, letter page with a
# 1.1 in left and 1 in right margin, 72 pt top margin, 21 numbered lines. Page furniture:
#   header1.xml  the numbers 1 to 21 in one floating text box anchored to the page (not counted as text);
#   footer1.xml  "TITLE - N" (PAGE field); docx/render.sh fills the title from the sample's footer_title;
#   sectPr       letter size, margins, and the pleading rules (w:pgBorders: double at the left, single at the right).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, xmllint, perl)
set -eu
OUT=$1
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

cat > "$W/styles-new.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="PleadingBody"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="PleadingBody"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="PleadingBody"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="TOCHeading"><w:name w:val="TOC Heading"/><w:basedOn w:val="Heading1"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="TOC1"><w:name w:val="toc 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9216"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/><w:ind w:left="0" w:right="576" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC2"><w:name w:val="toc 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9216"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/><w:ind w:left="720" w:right="576" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingBody"><w:name w:val="Pleading Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingNumbered"><w:name w:val="Pleading Numbered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingList"><w:name w:val="Pleading List"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSingle"><w:name w:val="Pleading Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingCaption"><w:name w:val="Pleading Caption"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingCentered"><w:name w:val="Pleading Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingFlush"><w:name w:val="Pleading Flush"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSignature"><w:name w:val="Pleading Signature"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4032" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingQuote"><w:name w:val="Pleading Quote"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
XML
# replace the styles of the same id, then append the pleading styles
perl -0777 -i -pe '
  open my $f, "<", "$ENV{W}/styles-new.xml" or die; my $new = do { local $/; <$f> };
  my @ids = $new =~ /w:styleId="([^"]+)"/g;
  for my $id (@ids) { s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s; }
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  s{</w:styles>}{$new</w:styles>}s;
' word/styles.xml
xmllint --noout word/styles.xml

# header: the numbers 1 to 21 in one floating text box anchored to the page: x 0.2 in, width 0.45 in (right edge
# 0.65 in from the page edge, as in the typst template), top 1 in (the top margin), 21 exact 640-twip lines
{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  printf '%s\n' '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">'
  printf '%s' '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="251659264" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>182880</wp:posOffset></wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>914400</wp:posOffset></wp:positionV><wp:extent cx="411480" cy="8534400"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="1" name="Pleading line numbers"/><wp:cNvGraphicFramePr/><a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="411480" cy="8534400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr><wps:txbx><w:txbxContent>'
  i=1
  while [ $i -le 21 ]; do
    printf '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="640" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>%s</w:t></w:r></w:p>' "$i"
    i=$((i + 1))
  done
  printf '%s' '</w:txbxContent></wps:txbx><wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0"><a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p>'
  printf '%s\n' '</w:hdr>'
} > word/header1.xml

# footer: "TITLE - N" on one line, left aligned at the text edge (render.sh fills TITLE; removed when empty)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t xml:space="preserve">@FOOTER_TITLE@ - </w:t></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML

# relationships and content types for the header and the footer
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# body section: letter; top 1 in (72 pt), bottom 940 twips (21 lines of 640 fit exactly), left 1.1 in, right 1 in;
# pleading rules: double at the left (14 pt from the text), single at the right (7 pt)
SECT='<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId102"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="940" w:left="1584" w:header="720" w:footer="520" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:cols w:space="720"/></w:sectPr>'
perl -0777 -i -pe 's{<w:sectPr\b.*?</w:sectPr>}{}s; s{</w:body>}{'"$SECT"'</w:body>}s' word/document.xml
for part in word/styles.xml word/document.xml word/header1.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
