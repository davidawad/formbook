#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the D. Alaska memorandum (akd), DOCX engine.
# Mirrors typst/akd-motion-brief.typ: EB Garamond 13 pt (L.R. 7.5(a)(1)(D)); double line pitch (34.5 pt) for body
# text (L.R. 7.5(a)(1)(A)); single 17 pt for the counsel block, caption, contents, authorities, signature and footer;
# letter size, 1 in margins (L.R. 7.5(a)(1)(B), (a)(2)(A)). The final section (the body) is numbered from 1
# (decimal). The cover, contents and authorities are a first section in lower roman, which docx/render.sh
# writes into the body. Footer text is filled in by docx/render.sh from the sample frontmatter.
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
my $DBL = 'w:line="690" w:lineRule="exact"';
my $SGL = 'w:line="340" w:lineRule="exact"';
my %S = (
Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$DBL.'/><w:ind w:firstLine="0"/></w:pPr><w:rPr>'.$FONT.'<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$DBL.'/><w:ind w:firstLine="720"/></w:pPr></w:style>',
FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$DBL.'/><w:ind w:firstLine="720"/></w:pPr></w:style>',
Compact => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$SGL.'/><w:ind w:firstLine="0"/></w:pPr></w:style>',
Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="390" w:after="390" '.$DBL.'/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="390" w:after="390" '.$SGL.'/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="390" w:after="390" '.$SGL.'/><w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Heading4 => '<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2160"/></w:tabs><w:spacing w:before="390" w:after="390" '.$SGL.'/><w:ind w:left="2160" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Heading5 => '<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2880"/></w:tabs><w:spacing w:before="390" w:after="390" '.$SGL.'/><w:ind w:left="2880" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
BlockText => '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="120" w:after="180" '.$SGL.'/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>',
FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Footer => '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" '.$SGL.'/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>',
Single => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$SGL.'/><w:ind w:firstLine="0"/></w:pPr></w:style>',
SingleIndent => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleIndent"><w:name w:val="SingleIndent"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>',
Centered => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>',
CourtTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="CourtTitle"/><w:basedOn w:val="Centered"/><w:qFormat/><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>',
DocTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="DocTitle"><w:name w:val="DocTitle"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="390" w:after="390" '.$SGL.'/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>',
Body => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Body"><w:name w:val="Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$DBL.'/><w:ind w:firstLine="720"/></w:pPr></w:style>',
Relief => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Relief"><w:name w:val="Relief"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" '.$DBL.'/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>',
Quote => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Quote"><w:name w:val="Quote"/><w:basedOn w:val="BlockText"/><w:qFormat/></w:style>',
SigBlock => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="SigBlock"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="3600" w:firstLine="0"/></w:pPr></w:style>',
Verification => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Verification"><w:name w:val="Verification"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" '.$DBL.'/><w:ind w:firstLine="720"/></w:pPr></w:style>',
TOCTitle => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCTitle"><w:name w:val="TOCTitle"/><w:basedOn w:val="Heading1"/><w:qFormat/><w:pPr><w:keepNext/><w:outlineLvl w:val="9"/></w:pPr></w:style>',
PageLabel => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="PageLabel"><w:name w:val="PageLabel"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
TOCEntry1 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry1"><w:name w:val="TOCEntry1"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="240" w:after="0" '.$SGL.'/><w:ind w:left="0" w:right="720" w:firstLine="0"/></w:pPr></w:style>',
TOCEntry2 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry2"><w:name w:val="TOCEntry2"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" '.$SGL.'/><w:ind w:left="720" w:right="720" w:hanging="720"/></w:pPr></w:style>',
TOCEntry3 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry3"><w:name w:val="TOCEntry3"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1440"/><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" '.$SGL.'/><w:ind w:left="1440" w:right="720" w:hanging="720"/></w:pPr></w:style>',
TOCEntry4 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry4"><w:name w:val="TOCEntry4"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2160"/><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" '.$SGL.'/><w:ind w:left="2160" w:right="720" w:hanging="720"/></w:pPr></w:style>',
TOAGroup => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAGroup"><w:name w:val="TOAGroup"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="200" w:after="60" '.$SGL.'/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
TOAEntry => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAEntry"><w:name w:val="TOAEntry"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="80" w:after="0" '.$SGL.'/><w:ind w:left="504" w:right="720" w:hanging="504"/></w:pPr></w:style>',
);
my $n = 0;
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

# footer: page number (PAGE field, cached 1), then the short title and the case line (filled in by render.sh)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:t>@FOOTER_TITLE@</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:t>@FOOTER_CASE@</w:t></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# final section (the body): letter, 1 in margins, the footer, page numbers from 1 in decimal
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="360" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' '[Content_Types].xml' 0 0 > /dev/null
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add_file "$f" "$f" 0 0 > /dev/null
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
