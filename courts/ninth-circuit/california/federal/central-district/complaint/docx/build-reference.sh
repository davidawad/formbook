#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the C.D. Cal. complaint (cacd), DOCX engine.
# Mirrors typst/cacd-complaint.typ: EB Garamond 14 pt (L.R. 11-3.1.1); exact 24 pt (double) line pitch on the
# 28-line grid (L.R. 11-3.2, 11-3.6); single 16 pt for counsel, caption and signature blocks; letter size, top
# margin 1 in, bottom margin 48 pt (28 lines end at 10.33 in); numbered left margin and pleading rules, drawn by
# a header frame (numbers 1 to 28) and page borders (rules); a footer with the page number, the paper title and
# the case number (the two text lines are filled in by docx/render.sh from the sample's frontmatter).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, perl, xmllint, zip)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
cat > "$W/styles.pl" <<'PERL'
my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $EXACT24 = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $EXACT16 = '<w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/>';
my %S = (
Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>'.$EXACT24.'<w:ind w:firstLine="0"/></w:pPr><w:rPr>'.$FONT.'<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>',
BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$EXACT24.'<w:ind w:firstLine="0"/></w:pPr></w:style>',
FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>'.$EXACT24.'<w:ind w:firstLine="0"/></w:pPr></w:style>',
Compact => '<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>'.$EXACT16.'<w:ind w:firstLine="0"/></w:pPr></w:style>',
Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'.$EXACT24.'<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>',
Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'.$EXACT24.'<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>',
Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'.$EXACT24.'<w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>',
FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="320" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>',
Header => '<w:style w:type="paragraph" w:styleId="Header"><w:name w:val="header"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr></w:style>',
Footer => '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:pos="9000"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>',
LineNumber => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="LineNumber"><w:name w:val="LineNumber"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$EXACT24.'<w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>',
Single => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$EXACT16.'<w:ind w:firstLine="0"/></w:pPr></w:style>',
Centered => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>',
CourtTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="CourtTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
Allegation => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>'.$EXACT24.'<w:ind w:firstLine="720"/></w:pPr></w:style>',
LeadIn => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="LeadIn"><w:name w:val="LeadIn"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$EXACT24.'<w:ind w:firstLine="720"/></w:pPr></w:style>',
ListItem => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="ListItem"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs>'.$EXACT24.'<w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>',
Quote => '<w:style w:type="paragraph" w:styleId="Quote"><w:name w:val="Quote"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="29"/><w:qFormat/><w:pPr>'.$EXACT24.'<w:ind w:left="1440" w:right="1440" w:firstLine="0"/></w:pPr></w:style>',
TableNormal => '<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>',
);
local $/;
my $f = "word/styles.xml";
open my $in, "<:encoding(UTF-8)", $f or die; my $x = <$in>; close $in;
$x =~ s{<w:rFonts w:asciiTheme="(minor|major)HAnsi"[^>]*/>}{$FONT}g;
for my $id (sort keys %S) {
  if ($x =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$S{$id}}s) { next }
  $x =~ s{</w:styles>}{$S{$id}</w:styles>}s;
}
open my $out, ">:encoding(UTF-8)", $f or die; print $out $x; close $out;
PERL
perl "$W/styles.pl"

# header: an empty paragraph, and a text box at the left margin (page-anchored, behind the text) holding the line numbers 1 to 28 on the 24 pt grid
{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  printf '%s' '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><w:p><w:pPr><w:pStyle w:val="Header"/></w:pPr><w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="251659264" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>914400</wp:posOffset></wp:positionV><wp:extent cx="987552" cy="8534400"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="101" name="LineNumbers"/><wp:cNvGraphicFramePr/><a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="987552" cy="8534400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr><wps:txbx><w:txbxContent>'
  i=1
  while [ $i -le 28 ]; do
    printf '<w:p><w:pPr><w:pStyle w:val="LineNumber"/></w:pPr><w:r><w:t>%s</w:t></w:r></w:p>' "$i"
    i=$((i + 1))
  done
  printf '%s\n' '</w:txbxContent></wps:txbx><wps:bodyPr lIns="0" tIns="0" rIns="0" bIns="0" anchor="t"><a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p></w:hdr>'
} > word/header1.xml

# footer: the page number (PAGE field), then the paper title and the case number (placeholders)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p><w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="6700"/><w:gridCol w:w="2300"/></w:tblGrid><w:tr><w:tc><w:tcPr><w:tcW w:w="6700" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:rPr><w:caps/></w:rPr><w:t>@FOOTER_TITLE@</w:t></w:r></w:p></w:tc><w:tc><w:tcPr><w:tcW w:w="2300" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="right"/></w:pPr><w:r><w:t>@FOOTER_CASE@</w:t></w:r></w:p></w:tc></w:tr></w:tbl><w:p><w:pPr><w:pStyle w:val="Footer"/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /></Types>|' '[Content_Types].xml'

# body section: letter; top 1 in; bottom 48 pt (28 lines of 24 pt from 72 pt); left 1.5 in; right 0.75 in;
# pleading rules: a double rule 0.2 in left of the text, a single rule 0.1 in right of the text's right edge
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="144" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="auto"/><w:right w:val="single" w:sz="4" w:space="7" w:color="auto"/></w:pgBorders></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/header1.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
