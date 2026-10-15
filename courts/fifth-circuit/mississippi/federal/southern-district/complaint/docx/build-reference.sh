#!/bin/sh
# Builds docx/reference.docx for the S.D. Miss. complaint from pandoc's default reference (docs/DOCX.md).
# Matches complaint/typst/mssd-complaint.typ: US Letter, 1 in margins; EB Garamond 13 pt (vendored); exact 27.6 pt
# double spacing with a 0.5 in first-line indent; single-spaced lines (exact 11.7 pt, the typst pitch) for the
# caption, headings and signature block; 12 pt footnotes; page number centered in the footer (PAGE field).
# Paragraph styles only: the allegation numbers and the list letters are typed by mssd-complaint.lua, followed by a
# tab to the tab stop in the style (pandoc drops a reference.docx numbering part, so no auto-numbering).
# Content-agnostic: no case text here; mssd-complaint.lua builds the cover, caption and signature from the sample.
# Usage: sh complaint/docx/build-reference.sh <out.docx>      (needs pandoc, unzip, zip, perl, xmllint)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/ref.docx"

cat > "$W/fix.pl" <<'PL'
use strict; use warnings;
my $dir = shift;
local $/;
sub slurp { my $p = shift; open my $f, '<', $p or die "$p: $!"; my $s = <$f>; close $f; $s }
sub spit  { my ($p, $s) = @_; open my $f, '>', $p or die "$p: $!"; print $f $s; close $f }

# styles.xml: document defaults, the styles this template redefines, and the custom styles.
my $st = slurp("$dir/word/styles.xml");
my $defaults = <<'XML';
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
XML
$st =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults";
my $new = <<'XML';
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Allegation"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1368"/></w:tabs><w:ind w:left="0" w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1368"/></w:tabs><w:ind w:left="1368" w:hanging="648"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="234" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverTitle"><w:name w:val="Cover Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:u w:val="single"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="234" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionBlock"><w:name w:val="Caption Block"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="130" w:after="0" w:line="234" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="380" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="4320" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigRole"><w:name w:val="Signature Role"/><w:basedOn w:val="SigBlock"/><w:qFormat/><w:pPr><w:spacing w:before="260" w:after="0" w:line="234" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
XML
for my $id ($new =~ /w:styleId="([^"]+)"/g) {
  $st =~ s{<w:style\s[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s;
}
$st =~ s{</w:styles>}{$new</w:styles>} or die "no </w:styles>";
spit("$dir/word/styles.xml", $st);

# document.xml: the body section (US Letter, 1 in margins, footer), and the footer relationship.
my $doc = slurp("$dir/word/document.xml");
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
$doc =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s or $doc =~ s{</w:body>}{$sect</w:body>}s;
spit("$dir/word/document.xml", $doc);
my $rels = slurp("$dir/word/_rels/document.xml.rels");
$rels =~ s{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>}s;
spit("$dir/word/_rels/document.xml.rels", $rels);
my $ct = slurp("$dir/[Content_Types].xml");
$ct =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}s;
spit("$dir/[Content_Types].xml", $ct);
PL
perl "$W/fix.pl" "$W/pkg"

# footer: the page number (PAGE field, cached result 1), centered
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
for part in word/styles.xml word/document.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
