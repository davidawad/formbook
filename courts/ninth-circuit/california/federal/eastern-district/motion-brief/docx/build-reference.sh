#!/bin/sh
# Builds docx/reference.docx for the E.D. Cal. motion (caed motion-brief), DOCX engine (docs/DOCX.md).
# Mirrors typst/caed-motion-brief.typ: EB Garamond 12 pt; double spacing as exact 24 pt lines (L.R. 130(c));
# single spacing as exact 13.8 pt for counsel, caption, tables and signature; letter size, top margin 1 in,
# 28 lines of 24 pt between the top margin and the footer, left margin 1.5 in, right 0.75 in; numbered lines
# 1 to 28 in the left margin (header frame, L.R. 130(b)); a double rule at the text's left edge and a single
# rule at its right (page borders); the footer (description and page number on one line, L.R. 130(d)).
# The final section numbers its pages in arabic from 1 (the memorandum); docx/render.sh adds the
# section breaks' footers and headers. Nothing case-specific is written here.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, perl, xmllint, ziptool from libzip)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

cat > "$W/styles.pl" <<'PERL'
my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $DBL = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SGL = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>';
my %S = (
Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>'.$DBL.'<w:ind w:firstLine="0"/><w:widowControl/></w:pPr><w:rPr>'.$FONT.'<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$DBL.'<w:ind w:firstLine="720"/></w:pPr></w:style>',
FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>'.$DBL.'<w:ind w:firstLine="720"/></w:pPr></w:style>',
Compact => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>'.$DBL.'<w:ind w:firstLine="0"/></w:pPr></w:style>',
Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'.$DBL.'<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'.$DBL.'<w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'.$DBL.'<w:ind w:left="1440" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Relief => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Relief"><w:name w:val="Relief"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1476"/></w:tabs>'.$DBL.'<w:ind w:left="1476" w:hanging="756"/></w:pPr></w:style>',
Single => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$SGL.'<w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
Centered => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>',
CourtTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="CourtTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
PageRight => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="PageRight"><w:name w:val="PageRight"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
TOCTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCTitle"><w:name w:val="TOCTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
TOCEntry1 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry1"><w:name w:val="TOCEntry1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9000"/></w:tabs>'.$DBL.'<w:ind w:left="720" w:hanging="720" w:firstLine="0"/></w:pPr><w:rPr><w:caps/></w:rPr></w:style>',
TOCEntry2 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry2"><w:name w:val="TOCEntry2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9000"/></w:tabs>'.$DBL.'<w:ind w:left="1440" w:hanging="720" w:firstLine="0"/></w:pPr></w:style>',
TOAGroup => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAGroup"><w:name w:val="TOAGroup"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/>'.$DBL.'<w:ind w:firstLine="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
TOAEntry => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAEntry"><w:name w:val="TOAEntry"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9000"/></w:tabs><w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:left="576" w:hanging="576" w:firstLine="0"/></w:pPr></w:style>',
MemoTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="MemoTitle"><w:name w:val="MemoTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
NoticeFirst => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="NoticeFirst"><w:name w:val="NoticeFirst"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>',
TOAPage => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAPage"><w:name w:val="TOAPage"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:pageBreakBefore/><w:keepNext/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
SigBlock => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="SigBlock"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:ind w:left="5040" w:firstLine="0"/></w:pPr></w:style>',
Footer => '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:pos="9000"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>',
Header => '<w:style w:type="paragraph" w:styleId="Header"><w:name w:val="header"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
LineNo => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="LineNo"><w:name w:val="LineNo"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>'.$DBL.'<w:jc w:val="right"/></w:pPr></w:style>',
FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
TableNormal => '<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>',
BodyKeep => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="BodyKeep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>',
SingleKeep => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleKeep"><w:name w:val="SingleKeep"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>',
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

# header: the numbered lines 1 to 28 (one frame anchored to the page, exact 24 pt rows from the top margin)
{
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  printf '%s' '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
  i=1
  while [ $i -le 28 ]; do
    printf '%s' '<w:p><w:pPr><w:pStyle w:val="LineNo"/><w:framePr w:w="1555" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="1440"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:t>'"$i"'</w:t></w:r></w:p>'
    i=$((i + 1))
  done
  printf '%s\n' '<w:p><w:pPr><w:pStyle w:val="Header"/></w:pPr></w:p></w:hdr>'
} > word/header1.xml

# footer: description (left, caps) and PAGE field (right) on one line; docx/render.sh fills the placeholder
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:rPr><w:caps/></w:rPr><w:t xml:space="preserve">@FOOTER_TITLE@</w:t></w:r><w:r><w:tab/></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rId101" Target="header1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml" /></Types>|' '[Content_Types].xml'

# final section (the memorandum): letter; top 1 in; bottom 48 pt; left 1.5 in; right 0.75 in; footer 30 pt from
# the bottom edge; double rule left, single rule right (page borders); arabic page numbers from 1
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:headerReference w:type="default" r:id="rId101"/><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="600" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="12" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/header1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
