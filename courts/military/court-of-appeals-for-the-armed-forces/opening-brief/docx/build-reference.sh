#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (CAAF form, see ../typst/armfor-*.typ):
# EB Garamond 14 pt everywhere, exact 31.4 pt (double) body spacing with a 0.5 in first-line indent,
# single-spaced 14 pt footnotes, hanging heading styles, letter paper with 1 in margins, and a
# centered PAGE-field footer used by the front matter (roman) and the body (arabic).
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, perl, unzip and zip on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"
cat > "$W/styles.pl" <<'PERL'
# Replace or add paragraph styles (all widths in twips; 628 = 31.4 pt exact double spacing).
use strict;
my $f = shift;
local $/; open my $h, '<', $f or die; my $s = <$h>; close $h;
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
# document defaults: the font and size of every run
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$font<w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
my %def = (
  Normal => '<w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr><w:rPr>'.$font.'<w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>',
  BodyText => '<w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="720"/></w:pPr>',
  FirstParagraph => '<w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="720"/></w:pPr>',
  Compact => '<w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="720"/></w:pPr>',
  BlockText => '<w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="280" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr>',
  FootnoteText => '<w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr><w:rPr>'.$font.'<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>',
  Footer => '<w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="center" w:pos="4680"/><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr>'.$font.'<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr>',
  Heading1 => '<w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="420" w:after="308" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr>',
  SectionHead => '<w:name w:val="Section Head"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="420" w:after="308" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr>',
  PointHead => '<w:name w:val="Point Head"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="336" w:after="280" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr>',
);
for my $id (sort keys %def) {
  my $body = $def{$id};
  my $custom = ($id =~ /^(SectionHead|PointHead|Hang[1-4])$/) ? ' w:customStyle="1"' : '';
  my $new = qq{<w:style w:type="paragraph"$custom w:styleId="$id">$body</w:style>};
  my $n = ($s =~ s{<w:style [^>]*w:styleId="$id"[^>]*>.*?</w:style>}{$new}s);
  $s =~ s{</w:styles>}{$new</w:styles>} unless $n;
}
my $keep = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepBody"><w:name w:val="Keep Body"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="720"/></w:pPr></w:style>};
$s =~ s{</w:styles>}{$keep</w:styles>};
my $top = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SectionHeadTop"><w:name w:val="Section Head Top"/><w:basedOn w:val="SectionHead"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="308" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>};
$s =~ s{</w:styles>}{$top</w:styles>};
# the custom heading styles for the body: label at 0.5, 1, 1.5, 2 in; text 0.5 in further (hanging)
for my $k (1 .. 4) {
  my $left = 720 * ($k + 1);
  my $new = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Hang$k"><w:name w:val="Hang $k"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="308" w:after="252" w:line="240" w:lineRule="auto"/><w:ind w:left="$left" w:hanging="720"/><w:jc w:val="left"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>};
  $s =~ s{</w:styles>}{$new</w:styles>};
}
for my $id (qw(SectionHead PointHead)) {
  # defined above; appended once here so that the file has them even when the reference lacks them
  next if $s =~ /w:styleId="$id"/;
  my $new = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id">$def{$id}</w:style>};
  $s =~ s{</w:styles>}{$new</w:styles>};
}
open my $o, '>', $f or die; print $o $s; close $o;
PERL
perl "$W/styles.pl" word/styles.xml
# theme fonts: headings and body use EB Garamond too (pandoc's default theme uses Aptos)
perl -pi -e 's/typeface="Aptos Display"/typeface="EB Garamond"/g; s/typeface="Aptos"/typeface="EB Garamond"/g' word/theme/theme1.xml
# the body section: letter, 1 in margins, PAGE footer, arabic numbering from 1 (the sections before it are roman or none)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/theme/theme1.xml; do xmllint --noout "$part"; done
# reproducible package: fixed file times, entries in a fixed order
find . -exec touch -h -d '@0' {} +
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X "$OUT" $(LC_ALL=C find _rels docProps word -type f | LC_ALL=C sort)
echo "$OUT"
