#!/bin/sh
# Builds docx/reference.docx for the ilnb adversary complaint from pandoc's default reference.docx.
# Mirrors typst/ilnb-adversary-complaint.typ: EB Garamond 13 pt; exact 24 pt (double) body pitch; 0.5 in
# first-line indent for body text and numbered paragraphs; US Letter, 1 in margins; centred 12 pt PAGE field in
# the footer; headings: level 1 centred bold capitals, level 2 bold, level 3 bold italic.
# Custom paragraph styles (named as in ilnb.lua): Centered, Single, Blank, Court Title, Cover Title,
# Caption Entry, Caption Designation, Numbered Paragraph, Prayer Item, Signature Column.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx
cat > "$W/edit-styles.pl" <<'PERL'
use strict; use warnings;
my $file = shift;
local $/;
open my $fh, '<:encoding(UTF-8)', $file or die "open $file: $!";
my $x = <$fh>;
close $fh;
my $F = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>';
my %def = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>$DOUBLE<w:ind w:firstLine="0"/></w:pPr></w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr>$DOUBLE<w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>$DOUBLE<w:ind w:firstLine="720"/></w:pPr></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$DOUBLE<w:ind w:firstLine="0"/></w:pPr></w:style>},
  Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>},
  Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>},
  Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
  Centered => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  Single => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine="0"/></w:pPr></w:style>},
  Blank => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Blank"><w:name w:val="Blank"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$DOUBLE<w:ind w:firstLine="0"/></w:pPr></w:style>},
  CourtTitle => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Centered"/><w:qFormat/><w:rPr><w:b/><w:bCs/></w:rPr></w:style>},
  CoverTitle => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverTitle"><w:name w:val="Cover Title"/><w:basedOn w:val="Centered"/><w:qFormat/><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>},
  CaptionEntry => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionEntry"><w:name w:val="Caption Entry"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/></w:pPr></w:style>},
  CaptionDesignation => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="2016" w:firstLine="0"/></w:pPr></w:style>},
  NumberedParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs>$DOUBLE<w:ind w:firstLine="720"/></w:pPr></w:style>},
  PrayerItem => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerItem"><w:name w:val="Prayer Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs>$DOUBLE<w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>},
  SignatureColumn => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureColumn"><w:name w:val="Signature Column"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="3888" w:firstLine="0"/></w:pPr></w:style>},
);
for my $id (sort keys %def) {
  my $re = qr{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}s;
  if ($x =~ $re) { $x =~ s/$re/$def{$id}/ } else { $x =~ s{</w:styles>}{$def{$id}</w:styles>} }
}
# document defaults: EB Garamond 13 pt (sz 26 half-points), no theme fonts
$x =~ s{<w:rPrDefault>.*?</w:rPrDefault>}{<w:rPrDefault><w:rPr>$F<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>}s
  or die "no rPrDefault in $file";
open my $out, '>:encoding(UTF-8)', $file or die "write $file: $!";
print $out $x;
close $out;
PERL
perl "$W/edit-styles.pl" word/styles.xml
# footer: centred PAGE field, 12 pt (cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# body section: replace the reference's final sectPr (one per document) with letter, 1 in margins, footer
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
