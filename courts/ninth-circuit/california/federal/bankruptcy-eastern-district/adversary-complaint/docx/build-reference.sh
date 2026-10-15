#!/bin/sh
# Builds docx/reference.docx for the caeb adversary complaint (DOCX engine, docs/DOCX.md).
# Mirrors typst/caeb-adversary-complaint.typ: Liberation Serif 13 pt (LBR 9004-2(a)(4)), exact 24 pt
# (double) line pitch on a 28-line grid, letter paper, top 1 in, bottom 0.667 in (28 lines fit exactly),
# left 1.5 in, right 0.75 in (LBR 9004-2(a)(1), (b)(2)). The numbered lines 1-28 are a frame in the page
# header (exact 24 pt, so they sit on the body grid); pleading rules are page borders; the page number is a
# PAGE field in the footer; page 1 also carries the page total (NUMPAGES) at the upper left (LBR 9004-2(c)).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, xmllint, unzip, and ziptool from libzip)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

FONT='<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif"/>'

# 1. styles: replace the pandoc styles we use; append the custom ones
cat > "$W/styles.pl" <<'PERL'
my %S = (
Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>FONT<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>',
FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>',
Compact => '<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:style>',
Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/></w:rPr></w:style>',
Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/></w:rPr></w:style>',
Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/></w:rPr></w:style>',
BlockText => '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="480" w:line="280" w:lineRule="exact"/><w:ind w:left="1440" w:right="1440" w:firstLine="0"/></w:pPr></w:style>',
FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Footer => '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>',
);
my $custom = join "", (
# numbered lines: a frame in the header, exact 24 pt, right-aligned
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="HeaderLine"><w:name w:val="Header Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="LineNumber"><w:name w:val="Line Number"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>',
# single spaced (counsel, caption, signature, quotation lines): exact 14 pt
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
# centered, double spaced (court title)
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
# numbered allegation: 0.5 in first line, the number, then a tab to 1 in
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>',
# unnumbered paragraph (lead-in, WHEREFORE): 0.5 in first line
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="LeadIn"><w:name w:val="Lead-in"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>',
# lettered item (a), (b): marker at 0.5 in, text at 1.15 in
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Relief"><w:name w:val="Relief"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1656"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1656" w:hanging="936" w:firstLine="0"/></w:pPr></w:style>',
);
local $/;
my $f = "word/styles.xml";
open my $in, "<:encoding(UTF-8)", $f or die; my $x = <$in>; close $in;
# document defaults: explicit body font instead of the theme font, 13 pt
$x =~ s{<w:rFonts w:asciiTheme="minorHAnsi"[^>]*/>}{$ENV{FONT}}g;
$x =~ s{<w:rFonts w:asciiTheme="majorHAnsi"[^>]*/>}{$ENV{FONT}}g;
for my $id (keys %S) {
  my $def = $S{$id}; $def =~ s/FONT/$ENV{FONT}/g;
  my $n = ($x =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$def}s);
  $custom .= $def unless $n;   # not in pandoc's reference: appended below
}
$x =~ s{</w:styles>}{$custom</w:styles>}s;
open my $out, ">:encoding(UTF-8)", $f or die; print $out $x; close $out;
PERL
export FONT
FONT=$FONT perl "$W/styles.pl"

# 2. header parts: the numbered lines 1-28 (in the default and the first-page header) and, on page 1, the page
# total. Each is a text box anchored to the page and not wrapped, so it takes no room in the header or the body.
PARAS=""
i=1
while [ "$i" -le 28 ]; do
  PARAS="$PARAS<w:p><w:pPr><w:pStyle w:val=\"LineNumber\"/></w:pPr><w:r><w:t>$i</w:t></w:r></w:p>"
  i=$((i + 1))
done
# textbox <id> <name> <x EMU> <y EMU> <w EMU> <h EMU> <paragraphs>: a wps text box anchored to the page
textbox() {
  printf '<w:p><w:pPr><w:pStyle w:val="HeaderLine"/></w:pPr><w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="%s" behindDoc="1" locked="0" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>%s</wp:posOffset></wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>%s</wp:posOffset></wp:positionV><wp:extent cx="%s" cy="%s"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="%s" name="%s"/><wp:cNvGraphicFramePr/><a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="%s" cy="%s"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr><wps:txbx><w:txbxContent>%s</w:txbxContent></wps:txbx><wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0"><a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p>' \
    "$((251658240 + $1))" "$3" "$4" "$5" "$6" "$1" "$2" "$5" "$6" "$7"
}
HDRNS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"'
# numbers: x 0.5 in, y 1 in (the top margin), 0.58 in wide, 672 pt tall (28 lines of 24 pt)
NUM_X=457200; NUM_Y=914400; NUM_W=530352; NUM_H=8534400
{ printf '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<w:hdr %s>' "$HDRNS"
  textbox 101 "Line numbers" $NUM_X $NUM_Y $NUM_W $NUM_H "$PARAS"
  printf '</w:hdr>\n'; } > word/header1.xml
# page total: x 1.5 in, y 0.5 in; first page only
PT_X=1371600; PT_Y=457200; PT_W=3931920; PT_H=279400
PT_PARA='<w:p><w:pPr><w:pStyle w:val="Single"/></w:pPr><w:r><w:t xml:space="preserve">Page total: </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> NUMPAGES </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
{ printf '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n<w:hdr %s>' "$HDRNS"
  textbox 102 "Line numbers" $NUM_X $NUM_Y $NUM_W $NUM_H "$PARAS"
  textbox 103 "Page total" $PT_X $PT_Y $PT_W $PT_H "$PT_PARA"
  printf '</w:hdr>\n'; } > word/header2.xml

# 3. footers: the page number (PAGE field) bottom center, default and first page
FTR='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>'
printf '%s\n' "$FTR" > word/footer1.xml
printf '%s\n' "$FTR" > word/footer2.xml

# relationships and content types for the four parts
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId100" Target="header1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header2.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId103" Target="footer2.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /><Override PartName="/word/header2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# 4. body section: letter, margins, pleading rules (page borders), first-page header, footers
SECT='<w:sectPr><w:headerReference w:type="default" r:id="rId100"/><w:headerReference w:type="first" r:id="rId101"/><w:footerReference w:type="default" r:id="rId102"/><w:footerReference w:type="first" r:id="rId103"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="432" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:titlePg/><w:docGrid w:linePitch="480"/></w:sectPr>'
export SECT
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{$ENV{SECT}}s' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: document.xml has no r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/header1.xml word/header2.xml word/footer1.xml word/footer2.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

# 5. zip (libzip's ziptool: no zip(1) on this box); [Content_Types].xml first
rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
