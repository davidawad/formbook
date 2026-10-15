#!/bin/sh
# Builds docx/reference.docx for the W.D. Wash. adversary complaint (docs/DOCX.md). Matches the typst template
# (../typst/wawb-adversary-complaint.typ): letter; 28 numbered lines on a 24 pt (480 twip) grid; top margin 1 in;
# bottom margin 48 pt (the 28 lines fill the rest); left margin 1.5 in; right 0.75 in; EB Garamond 12 pt; the
# pleading rules (w:pgBorders: double at the left, single at the right).
#   header     the 28 numbers in one floating text box anchored to the page (it does not grow the header)
#   footer     the bottom notation: a floating text box anchored to the page at 748 pt from the top, holding a table
#              with the abbreviated title and the page number at left and the counsel at right. Placeholders
#              (@FOOTER_*@) are filled by render.sh from the sample's frontmatter, so no case text lives here.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, xmllint, perl)
set -eu
OUT=$1
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

cat > "$W/styles-new.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="PleadingBody"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="PleadingBody"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="PleadingBody"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingBody"><w:name w:val="Pleading Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingFlush"><w:name w:val="Pleading Flush"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSingle"><w:name w:val="Pleading Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingCentered"><w:name w:val="Pleading Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingRight"><w:name w:val="Pleading Right"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingItem"><w:name w:val="Pleading Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="1296" w:hanging="576" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSignature"><w:name w:val="Pleading Signature"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingFooter"><w:name w:val="Pleading Footer"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="260" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
XML
# replace the styles of the same id, then append the pleading styles
perl -0777 -i -pe '
  open my $f, "<", "$ENV{W}/styles-new.xml" or die; my $new = do { local $/; <$f> };
  my @ids = $new =~ /w:styleId="([^"]+)"/g;
  for my $id (@ids) { s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s; }
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  s{</w:styles>}{$new</w:styles>}s;
' word/styles.xml
xmllint --noout word/styles.xml

# header: the 28 numbers in a floating text box (1 in from the top, right edge 0.42 in left of the text), 28 exact
# 480-twip lines, 12 pt. The header paragraph itself is empty and small.
{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  printf '%s\n' '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">'
  printf '%s' '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="251659264" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>352425</wp:posOffset></wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>914400</wp:posOffset></wp:positionV><wp:extent cx="635000" cy="8534400"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="1" name="Pleading line numbers"/><wp:cNvGraphicFramePr/><a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="635000" cy="8534400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr><wps:txbx><w:txbxContent>'
  i=1
  while [ $i -le 28 ]; do
    printf '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>%s</w:t></w:r></w:p>' "$i"
    i=$((i + 1))
  done
  printf '%s' '</w:txbxContent></wps:txbx><wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0"><a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p>'
  printf '%s\n' '</w:hdr>'
} > word/header1.xml

# footer: the bottom notation in a floating text box anchored to the page at 748 pt from the top (the typst
# template's footer position), 1.5 in from the left, 6.25 in wide. A two-cell table: left = title and page number,
# right = counsel (2.7 in wide, right aligned). Placeholders are filled by render.sh.
{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  printf '%s\n' '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">'
  printf '%s' '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="251660288" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>1371600</wp:posOffset></wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>9499600</wp:posOffset></wp:positionV><wp:extent cx="5715000" cy="508000"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="2" name="Bottom notation"/><wp:cNvGraphicFramePr/><a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="5715000" cy="508000"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr><wps:txbx><w:txbxContent>'
  printf '%s' '<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr><w:tblGrid><w:gridCol w:w="4824"/><w:gridCol w:w="288"/><w:gridCol w:w="3888"/></w:tblGrid><w:tr><w:tc><w:tcPr><w:tcW w:w="4824" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="PleadingFooter"/></w:pPr><w:r><w:t xml:space="preserve">@FOOTER_TITLE@ - </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:tc><w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr><w:p/></w:tc><w:tc><w:tcPr><w:tcW w:w="3888" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="PleadingFooter"/><w:jc w:val="right"/></w:pPr><w:r><w:t>@FOOTER_COUNSEL_1@</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="PleadingFooter"/><w:jc w:val="right"/></w:pPr><w:r><w:t>@FOOTER_COUNSEL_2@</w:t></w:r></w:p></w:tc></w:tr></w:tbl>'
  printf '%s' '</w:txbxContent></wps:txbx><wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0"><a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p>'
  printf '%s\n' '</w:ftr>'
} > word/footer1.xml

# relationships and content types for the header and the footer
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# body section: letter; top 1 in (72 pt); bottom 48 pt (960 twips); left 1.5 in; right 0.75 in; footer 0.2 in
SECT='<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId102"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="288" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:cols w:space="720"/></w:sectPr>'
perl -0777 -i -pe 's{<w:sectPr\b.*?</w:sectPr>}{}s; s{</w:body>}{'"$SECT"'</w:body>}s' word/document.xml
for part in word/styles.xml word/document.xml word/header1.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
