#!/bin/sh
# Builds docx/reference.docx for nynb adversary complaints from pandoc's default reference. The styles mirror
# typst/nynb-adversary-complaint.typ: EB Garamond 12 pt; body lines exact 24 pt (double spaced, typst pitch);
# single-spaced material (caption, signature, block quotes, footnotes) exact 13.8 pt; 1 in margins, letter;
# centred page number in the footer (PAGE field).
# Usage: sh docx/build-reference.sh <out.docx>     (needs pandoc, unzip, zip, xmllint, perl on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
unzip -q "$W/ref.docx" -d "$W/pkg"
perl - "$W/pkg" <<'PERL'
use strict; use warnings;
my $pkg = shift;
sub slurp { my $f = shift; open my $h, '<:encoding(UTF-8)', $f or die "$f: $!"; local $/; my $s = <$h>; close $h; $s }
sub spit { my ($f, $s) = @_; open my $h, '>:encoding(UTF-8)', $f or die "$f: $!"; print {$h} $s; close $h }

my $RF = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $ONE = '<w:sz w:val="24"/><w:szCs w:val="24"/>';
my $PITCH = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>';
my %style = (
  Normal => q{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>} . $PITCH . q{<w:ind w:firstLine="720"/></w:pPr><w:rPr>} . $RF . $ONE . q{</w:rPr></w:style>},
  BodyText => q{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>} . $PITCH . q{<w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>},
  Compact => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>},
  BlockText => q{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>} . $SINGLE . q{<w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
  Heading1 => q{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>} . $RF . q{<w:b/><w:bCs/><w:color w:val="000000"/>} . $ONE . q{</w:rPr></w:style>},
  Heading2 => q{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>} . $RF . q{<w:b/><w:bCs/><w:color w:val="000000"/>} . $ONE . q{</w:rPr></w:style>},
  Heading3 => q{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>} . $RF . q{<w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/>} . $ONE . q{</w:rPr></w:style>},
  FootnoteText => q{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>} . $ONE . q{</w:rPr></w:style>},
  Footer => q{<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr>} . $ONE . q{</w:rPr></w:style>},
  Single => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>} . $SINGLE . q{<w:ind w:firstLine="0"/></w:pPr></w:style>},
  Centered => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>},
  Numbered => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Numbered"><w:name w:val="Numbered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>},
  NumberedKeep => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedKeep"><w:name w:val="Numbered Keep"/><w:basedOn w:val="Numbered"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>},
  BodyKeep => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>},
  Prayer => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Prayer"><w:name w:val="Prayer"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>},
  PrayerKeep => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerKeep"><w:name w:val="Prayer Keep"/><w:basedOn w:val="Prayer"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>},
);

my $st = slurp("$pkg/word/styles.xml");
my $defaults = q{<w:docDefaults><w:rPrDefault><w:rPr>} . $RF . $ONE .
  q{<w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>};
$st =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults";
for my $id (sort keys %style) {
  my $xml = $style{$id};
  if ($st =~ s{<w:style\b[^>]*w:styleId="\Q$id\E".*?</w:style>}{$xml}s) { }
  else { $st =~ s{</w:styles>}{$xml</w:styles>}s or die "no </w:styles>" }
}
spit("$pkg/word/styles.xml", $st);

# footer: centred PAGE field (cached result 1)
spit("$pkg/word/footer1.xml", q{<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
});
my $rels = slurp("$pkg/word/_rels/document.xml.rels");
$rels =~ s{</Relationships>}{<Relationship Id="rIdNynbFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>} or die "rels";
spit("$pkg/word/_rels/document.xml.rels", $rels);
my $ct = slurp("$pkg/[Content_Types].xml");
$ct =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>} or die "types";
spit("$pkg/[Content_Types].xml", $ct);

# page setup: letter, 1 in margins, footer at 0.5 in
my $doc = slurp("$pkg/word/document.xml");
my $sect = q{<w:sectPr><w:footerReference w:type="default" r:id="rIdNynbFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>};
$doc =~ s{<w:sectPr\b.*?</w:sectPr>}{$sect}s or die "no sectPr";
spit("$pkg/word/document.xml", $doc);
PERL
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$W/pkg/$part"
done
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
rm -f "$OUT"
(cd "$W/pkg" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" _rels docProps word)
echo "$OUT"
