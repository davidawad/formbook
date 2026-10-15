#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../../../../../../docs/DOCX.md): the
# typst layout of typst/mnb-adversary-complaint.typ in Word styles. EB Garamond 12 pt; body double-spaced (24 pt exact
# line pitch), half-inch first-line indent; caption and signature lines single-spaced (13.8 pt exact); headings
# 16.8 pt and 14.4 pt, as typst's heading sizes; block quotations single-spaced and indented; letter page, 1-inch
# margins; a centred page number in the footer. Usage: sh docx/make-reference.sh [out.docx]
# (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"

cat > "$T/styles.pl" <<'PERL'
my %style = (
  Normal => q{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  BodyText => q{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>},
  Heading1 => q{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>},
  Heading2 => q{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>},
  Heading3 => q{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  BlockText => q{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="24" w:line="276" w:lineRule="exact"/><w:ind w:left="960" w:right="960" w:firstLine="0"/></w:pPr></w:style>},
  FootnoteText => q{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>},
  Single => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  SingleIndent => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleIndent"><w:name w:val="Single Indent"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="2592" w:firstLine="0"/></w:pPr></w:style>},
  SingleBold => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleBold"><w:name w:val="Single Bold"/><w:basedOn w:val="Single"/><w:qFormat/><w:rPr><w:b/><w:bCs/></w:rPr></w:style>},
  CourtTitle => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>},
  CenteredBold => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBold"><w:name w:val="Centered Bold"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>},
  GapTitle => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapTitle"><w:name w:val="Gap Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="660" w:lineRule="exact"/></w:pPr></w:style>},
  GapShort => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapShort"><w:name w:val="Gap Short"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/></w:pPr></w:style>},
  Gap => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>},
  ListItem => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="1296" w:firstLine="0"/></w:pPr></w:style>},
  ListLetter => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListLetter"><w:name w:val="List Letter"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>},
  BlockQuote => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BlockQuote"><w:name w:val="Block Quote"/><w:basedOn w:val="BlockText"/><w:qFormat/></w:style>},
  BlockQuoteFirst => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BlockQuoteFirst"><w:name w:val="Block Quote First"/><w:basedOn w:val="BlockText"/><w:qFormat/><w:pPr><w:spacing w:before="360"/></w:pPr></w:style>},
  BodyKeepNext => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeepNext"><w:name w:val="Body Keep Next"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>},
  FooterPage => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FooterPage"><w:name w:val="Footer Page"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr></w:style>},
);
my $defaults = q{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>};
local $/;
my $path = shift @ARGV;
open my $fh, '<', $path or die "$path: $!";
my $xml = <$fh>;
close $fh;
$xml =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults";
my $extra = '';
for my $id (sort keys %style) {
  my $new = $style{$id};
  if ($xml =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$new}s) {
    next;
  }
  $extra .= $new;
}
$xml =~ s{</w:styles>}{$extra</w:styles>}s;
open my $out, '>', $path or die "$path: $!";
print $out $xml;
close $out;
PERL
perl "$T/styles.pl" "$W/word/styles.xml"

cat > "$T/document.pl" <<'PERL'
my $path = shift @ARGV;
local $/;
open my $fh, '<', $path or die "$path: $!";
my $xml = <$fh>;
close $fh;
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="1200" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>';
$xml =~ s{<w:sectPr\b.*?</w:sectPr>}{$sect}s or die "no sectPr";
open my $out, '>', $path or die "$path: $!";
print $out $xml;
close $out;
PERL
perl "$T/document.pl" "$W/word/document.xml"

cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="FooterPage"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
