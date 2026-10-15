#!/bin/sh
# Builds docx/reference.docx for the azd motion with memorandum (DOCX engine, docs/DOCX.md). Mirrors
# typst/azd-motion.typ: EB Garamond 13 pt (LRCiv 7.1(b)(1)); exact 24 pt (double) line pitch, so 28 lines fill the text
# area; letter size, top margin 1 in, bottom margin 48 pt, left 1.5 in, right 0.75 in; pleading numbers 1 to 28 in a
# floating text box in each header; pleading rules from page borders; centred PAGE field in the footer.
# The running header (pages 2 on) is not in this file: it is case-specific, so docx/render.sh writes it from the
# sample's frontmatter into the placeholder <!--RUNNING--> of header1.xml.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, perl, xmllint and ziptool from libzip)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# 1. styles: drop the pandoc definitions of the ids we set, then append ours
cat > "$W/styles.pl" <<'PERL'
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my %S = (
Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>FONT<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>',
FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>',
Compact => '<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:line="300" w:lineRule="exact"/></w:pPr></w:style>',
Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="300" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Footer => '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="240" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr></w:style>',
Header => '<w:style w:type="paragraph" w:styleId="Header"><w:name w:val="header"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="240" w:lineRule="exact"/></w:pPr></w:style>',
Single => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:line="300" w:lineRule="exact"/></w:pPr></w:style>',
Centered => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>',
CHeadingOne => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CHeadingOne"><w:name w:val="Section Heading"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
MHeadingTwo => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="MHeadingTwo"><w:name w:val="Heading Level 2"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
MHeadingThree => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="MHeadingThree"><w:name w:val="Heading Level 3"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:left="1440" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
MHeadingFour => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="MHeadingFour"><w:name w:val="Heading Level 4"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2160"/></w:tabs><w:ind w:left="2160" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
MHeadingFive => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="MHeadingFive"><w:name w:val="Heading Level 5"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2880"/></w:tabs><w:ind w:left="2880" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>',
BodyPara => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyPara"><w:name w:val="Body Paragraph"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>',
LeadIn => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="LeadIn"><w:name w:val="Lead-in"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>',
RunningHeader => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="RunningHeader"><w:name w:val="Running Header"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>',
LineNumber => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="LineNumber"><w:name w:val="Pleading Line Number"/><w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="right"/></w:pPr></w:style>',
);
local $/;
my $f = "word/styles.xml";
open my $in, "<:encoding(UTF-8)", $f or die; my $x = <$in>; close $in;
# document defaults and the theme fonts: the court face, not the theme
$x =~ s{<w:rFonts w:asciiTheme="(?:minor|major)HAnsi"[^>]*/>}{$font}g;
for my $id (keys %S) {
  $x =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
}
my $add = join "", map { my $s = $S{$_}; $s =~ s/FONT/$font/; $s } sort keys %S;
$x =~ s{</w:styles>}{$add</w:styles>}s;
open my $out, ">:encoding(UTF-8)", $f or die; print $out $x; close $out;
PERL
perl "$W/styles.pl"

# 2. headers: the default (pages 2 on) holds the running-header placeholder; the first page has none. Both carry
#    the pleading numbers 1 to 28 in a floating text box (VML), positioned on the page, so they take no header height.
numbers_box() {
  echo '<w:p><w:pPr><w:pStyle w:val="Header"/></w:pPr><w:r><w:pict>'
  echo '<v:shapetype id="_x0000_t202" coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe"><v:stroke joinstyle="miter"/><v:path gradientshapeok="t" o:connecttype="rect"/></v:shapetype>'
  echo '<v:shape id="PleadingNumbers" o:spid="_x0000_s1025" type="#_x0000_t202" filled="f" stroked="f" style="position:absolute;margin-left:0;margin-top:72pt;width:77.75pt;height:672pt;z-index:-251658752;mso-position-horizontal:absolute;mso-position-horizontal-relative:page;mso-position-vertical:absolute;mso-position-vertical-relative:page">'
  echo '<v:textbox inset="0,0,0,0"><w:txbxContent>'
  i=1
  while [ "$i" -le 28 ]; do
    printf '<w:p><w:pPr><w:pStyle w:val="LineNumber"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:jc w:val="right"/></w:pPr><w:r><w:t>%s</w:t></w:r></w:p>\n' "$i"
    i=$((i + 1))
  done
  echo '</w:txbxContent></v:textbox></v:shape></w:pict></w:r></w:p>'
}
HDR_OPEN='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">'
{
  echo "$HDR_OPEN"
  echo '<!--RUNNING-->'
  numbers_box
  echo '</w:hdr>'
} > word/header1.xml
{
  echo "$HDR_OPEN"
  numbers_box
  echo '</w:hdr>'
} > word/header2.xml
xmllint --noout word/header1.xml word/header2.xml

# 3. footers: the page number (PAGE field, cached result 1), for the first page and the others
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cp word/footer1.xml word/footer2.xml
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer2.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId103" Target="header2.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /><Override PartName="/word/header2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /></Types>|' '[Content_Types].xml'

# 4. body section: letter; top 1 in, bottom 48 pt, left 1.5 in, right 0.75 in; header 0.25 in (the running header
#    fits in the top margin, from 14 pt as in typst); first page without the running header (titlePg); pleading rules
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:headerReference w:type="first" r:id="rId103"/><w:footerReference w:type="default" r:id="rId100"/><w:footerReference w:type="first" r:id="rId102"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="360" w:footer="360" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="12" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:titlePg/></w:sectPr>}s' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: document.xml has no r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml word/header1.xml word/header2.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

# 5. zip (libzip's ziptool: no zip(1) on this box); [Content_Types].xml first
rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
