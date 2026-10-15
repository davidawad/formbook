#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (canb, adversary complaint; see README "Engines").
# Mirrors typst/canb-adversary-complaint.typ: EB Garamond 12 pt, exact 24 pt (double) pitch, 28 numbered lines
# per page in a header frame (pleading paper), double rule at the left text edge and single at the right
# (page borders), letter size, top margin 1 in, bottom margin 48 pt, centered page number in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, perl, xmllint, and ziptool from libzip)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# 1. style definitions (twips: 20 per pt; 480 = 24 pt pitch; 276 = 13.8 pt single)
cat > "$W/styles.pl" <<'PERL'
my %S = (
Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
Compact => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:style>',
Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
BlockText => '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>',
FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Footer => '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>',
Table => '<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tblBorders><w:tblCellMar><w:top w:w="72" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="72" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>',
);
my $custom = join "", (
'<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1368"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="LeadIn"><w:name w:val="Lead-in"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="Relief"><w:name w:val="Relief"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1728"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1728" w:hanging="1008" w:firstLine="0"/></w:pPr></w:style>',
'<w:style w:type="paragraph" w:customStyle="1" w:styleId="TableTitle"><w:name w:val="Table Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
);
local $/;
my $f = "word/styles.xml";
open my $in, "<:encoding(UTF-8)", $f or die; my $x = <$in>; close $in;
# document defaults: explicit body font instead of the theme font
$x =~ s{<w:rFonts w:asciiTheme="minorHAnsi"[^>]*/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>}g;
$x =~ s{<w:rFonts w:asciiTheme="majorHAnsi"[^>]*/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>}g;
for my $id (keys %S) {
  my $n = ($x =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$S{$id}}s);
  # a style pandoc does not ship (Footer, Table in some pandoc versions) is appended
  $x =~ s{</w:styles>}{$S{$id}</w:styles>}s unless $n;
}
$x =~ s{</w:styles>}{$custom</w:styles>}s;
open my $out, ">:encoding(UTF-8)", $f or die; print $out $x; close $out;
PERL
perl "$W/styles.pl"

# 2. header: the 28 numbered lines (1 to 28, exact 24 pt pitch) in one frame at the top margin, right-aligned
# in the left margin (pleading paper). One paragraph with line breaks, so the frame is a single object.
NUMS=""
i=1
while [ $i -le 28 ]; do
  [ $i -gt 1 ] && NUMS="$NUMS<w:r><w:br/></w:r>"
  NUMS="$NUMS<w:r><w:t>$i</w:t></w:r>"
  i=$((i + 1))
done
cat > word/header1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:framePr w:w="1555" w:h="13440" w:hRule="exact" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="1440"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:r>$NUMS</w:p><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p></w:hdr>
XML
xmllint --noout word/header1.xml

# 3. footer with the page number between dashes (typst: "-1-"), PAGE field with cached result 1
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:t xml:space="preserve">-</w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:r><w:t xml:space="preserve">-</w:t></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /></Types>|' '[Content_Types].xml'

# 4. body section: letter; margins top 1 in, left 1.5 in, right 0.75 in, bottom 48 pt (28 lines of 24 pt exactly
# fill the text area); page borders: double rule at the left text edge, single at the right
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="288" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="6" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="5" w:color="000000"/></w:pgBorders><w:cols w:space="720"/></w:sectPr>}s' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: document.xml has no r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml word/header1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

# 5. zip (libzip's ziptool: no zip(1) on this box); [Content_Types].xml first
rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
