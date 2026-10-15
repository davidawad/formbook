#!/bin/sh
# Builds docx/reference.docx for the N.D. W. Va. motion (typst/wvnb-motion-brief.typ, the reference for the form):
# EB Garamond 12 pt, exact 18 pt line pitch (the typst body pitch: 12 pt text, body-leading 0.85em), single
# blocks at the typst single pitch (11.4 pt), 1 in margins, letter, 0.5 in first-line indent, centered page
# number in the footer (10 pt). Starts from pandoc's default reference.docx; styles are replaced by styleId.
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, xmllint, unzip, zip on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
LINE=360    # body pitch, twips (18 pt)
SINGLE=228  # single blocks, twips (11.4 pt)
export LINE SINGLE
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/edit.pl" <<'PL'
use strict;
my ($file) = @ARGV;
open my $fh, '<', $file or die "$file: $!";
local $/;
my $x = <$fh>;
close $fh;
my $L = $ENV{LINE};
my $S = $ENV{SINGLE};
my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
# every font reference (docDefaults, heading styles, ...) names the vendored face; no theme fonts remain
$x =~ s{<w:rFonts [^>]*/>}{$FONT}g;
my %st = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="$L" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$L" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$L" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$S" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="288" w:after="192" w:line="$L" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$FONT<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="144" w:line="$L" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$FONT<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="144" w:line="$L" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$FONT<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$L" w:lineRule="exact"/><w:ind w:left="240" w:right="240" w:firstLine="0"/></w:pPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$FONT<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>},
  Footer => qq{<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr>$FONT<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>},
  Single => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$S" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>},
  Centered => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>},
  CenteredBody => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBody"><w:name w:val="Centered Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  SigBlock => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="4608" w:firstLine="0"/></w:pPr></w:style>},
  SigSingle => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigSingle"><w:name w:val="Signature Block Single"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="4608" w:firstLine="0"/></w:pPr></w:style>},
);
for my $id (qw(Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 BlockText FootnoteText Footer Single Centered CenteredBody SigBlock SigSingle)) {
  my $new = $st{$id};
  my $re = qr{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}s;
  if ($x =~ $re) { $x =~ s{$re}{$new}s } else { $x =~ s{</w:styles>}{$new</w:styles>}s }
}
open my $out, '>', $file or die;
print $out $x;
close $out;
PL
perl "$W/edit.pl" word/styles.xml
# the sample's page-number footer (PAGE field, cached result 1) and the body section: letter, 1 in margins
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
