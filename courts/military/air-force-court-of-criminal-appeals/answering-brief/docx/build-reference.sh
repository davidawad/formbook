#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, to the AFCCA form of typst/afcca-opening-brief.typ:
# EB Garamond 12 pt; body double-spaced at an exact 27 pt line (the typst pitch, 0.94em leading); first-line
# indent 0.5 in; single spacing (17.1 pt exact) for captions, footnotes, block quotations, headings and
# TOC/TOA; 1 in margins on US Letter; a centered PAGE field in the footer. Styles used by afcca.lua are defined here.
# The same file is used by answering-brief/docx/build-reference.sh (the two typst templates differ only in doc-kind).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip on PATH; works in a temp dir only)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/ref.docx"
perl - <<'PL'
use strict;
use warnings;
my $f = "word/styles.xml";
open my $in, '<:encoding(UTF-8)', $f or die "$f: $!";
local $/;
my $s = <$in>;
close $in;

my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $DBL = 540;      # exact 27 pt: double spacing as typst renders it
my $SGL = 342;      # exact 17.1 pt: single spacing as typst renders it
my $TAB = 9360;     # right margin, 6.5 in

sub remove_style {
  my ($id) = @_;
  $s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
}
sub add_style { my ($xml) = @_; $s =~ s{</w:styles>}{$xml\n</w:styles>}s or die "no </w:styles>"; }

# name, id, pPr (ordered children), rPr (children), basedOn
sub para_style {
  my (%o) = @_;
  my $custom = $o{custom} ? ' w:customStyle="1"' : '';
  my $default = $o{default} ? ' w:default="1"' : '';
  my $based = $o{based} // 'Normal';
  my $based_xml = $o{id} eq 'Normal' ? '' : qq{<w:basedOn w:val="$based"/>};
  return qq{<w:style w:type="paragraph"$default$custom w:styleId="$o{id}"><w:name w:val="$o{name}"/>$based_xml<w:qFormat/><w:pPr>$o{ppr}</w:pPr><w:rPr>$o{rpr}</w:rPr></w:style>};
}
sub spacing { my ($b, $a, $line) = @_; return qq{<w:spacing w:before="$b" w:after="$a" w:line="$line" w:lineRule="exact"/>} }
sub single { return spacing(@_[0..1], $SGL) }

# document defaults: EB Garamond 12 pt, no space after
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s or die "no docDefaults";

my @styles = (
  para_style(id => 'Normal', name => 'Normal', default => 1,
    ppr => '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="left"/>',
    rpr => $FONT . '<w:sz w:val="24"/><w:szCs w:val="24"/>'),
  para_style(id => 'BodyText', name => 'Body Text', based => 'Normal',
    ppr => spacing(0, 0, $DBL) . '<w:ind w:firstLine="720"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'FirstParagraph', name => 'First Paragraph', based => 'Normal',
    ppr => spacing(0, 0, $DBL) . '<w:ind w:firstLine="720"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'Compact', name => 'Compact', based => 'Normal',
    ppr => spacing(0, 0, $DBL) . '<w:ind w:firstLine="720"/>', rpr => ''),
  para_style(id => 'BlockText', name => 'Block Text', based => 'Normal',   # block quotations: pad 0.5 in, single
    ppr => spacing(240, 240, $SGL) . '<w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'FootnoteText', name => 'Footnote Text', based => 'Normal',
    ppr => spacing(0, 120, $SGL) . '<w:ind w:firstLine="0"/>', rpr => '<w:sz w:val="24"/><w:szCs w:val="24"/>'),
  para_style(id => 'Centered', name => 'Centered', custom => 1,
    ppr => single(0, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => ''),
  para_style(id => 'SectionHeading', name => 'Section Heading', custom => 1,
    ppr => '<w:keepNext/><w:keepLines/>' . single(336, 240) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'SectionHeadingBreak', name => 'Section Heading Break', custom => 1,   # a section that starts a page
    ppr => '<w:keepNext/><w:keepLines/><w:pageBreakBefore/>' . single(0, 240) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'PointHeading', name => 'Point Heading', custom => 1,   # I., II. on their own line, text centered below
    ppr => '<w:keepNext/><w:keepLines/>' . single(288, 240) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'PointHeadingChained', name => 'Point Heading Chained', custom => 1,   # AOE and issues: not kept with the next
    ppr => '<w:keepLines/>' . single(288, 240) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'UnnumberedHeadingCentered', name => 'Unnumbered Heading Centered', custom => 1,
    ppr => '<w:keepNext/><w:keepLines/>' . single(264, 216) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'UnnumberedHeadingLeft', name => 'Unnumbered Heading Left', custom => 1,
    ppr => '<w:keepNext/><w:keepLines/>' . single(264, 216) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'SubHeading3', name => 'Sub Heading 3', custom => 1,   # A. : label at 0.5 in, text hangs at 1 in
    ppr => '<w:keepNext/><w:keepLines/>' . single(264, 216) . '<w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'SubHeading4', name => 'Sub Heading 4', custom => 1,   # 1. : label at 1 in, text hangs at 1.5 in
    ppr => '<w:keepNext/><w:keepLines/>' . single(264, 216) . '<w:ind w:left="2160" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'SubHeading5', name => 'Sub Heading 5', custom => 1,
    ppr => '<w:keepNext/><w:keepLines/>' . single(264, 216) . '<w:ind w:left="2880" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="4"/>',
    rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'CaptionLine', name => 'Caption Line', custom => 1,
    ppr => single(0, 72) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'CaptionVersus', name => 'Caption Versus', custom => 1,   # "v." and designations: 0.9 in and 1.6 in
    ppr => single(0, 72) . '<w:ind w:left="1296" w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'CaptionDesignation', name => 'Caption Designation', custom => 1,
    ppr => single(0, 72) . '<w:ind w:left="2304" w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'CaptionTitle', name => 'Caption Title', custom => 1,
    ppr => single(0, 72) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/>', rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'CourtLine', name => 'Court Line', custom => 1,
    ppr => single(0, 384) . '<w:keepNext/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'Spacer', name => 'Spacer', custom => 1,   # an empty line of 1.6 em (typst v(1.6em))
    ppr => '<w:spacing w:before="0" w:after="0" w:line="384" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => '<w:sz w:val="2"/>'),
  para_style(id => 'Honorable', name => 'Honorable', custom => 1,
    ppr => single(384, 240) . '<w:keepNext/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'HonorableTop', name => 'Honorable Top', custom => 1,
    ppr => single(0, 240) . '<w:keepNext/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'CounselBlock', name => 'Counsel Block', custom => 1,
    ppr => single(0, 340) . '<w:ind w:left="936" w:right="936" w:firstLine="0"/><w:jc w:val="center"/>', rpr => ''),
  para_style(id => 'TocPageLabel', name => 'Toc Page Label', custom => 1,
    ppr => single(72, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="right"/>', rpr => '<w:b/><w:bCs/><w:u w:val="single"/>'),
  para_style(id => 'TocEntry1', name => 'Toc Entry 1', custom => 1,
    ppr => '<w:keepLines/>' . single(144, 0) . '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' . $TAB . '"/></w:tabs><w:ind w:left="720" w:right="864" w:hanging="720"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'TocEntry2', name => 'Toc Entry 2', custom => 1,
    ppr => '<w:keepLines/>' . single(84, 0) . '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' . $TAB . '"/></w:tabs><w:ind w:left="720" w:right="864" w:hanging="720"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'TocEntry3', name => 'Toc Entry 3', custom => 1,
    ppr => '<w:keepLines/>' . single(84, 0) . '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' . $TAB . '"/></w:tabs><w:ind w:left="1440" w:right="864" w:hanging="720"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'TocEntry4', name => 'Toc Entry 4', custom => 1,
    ppr => '<w:keepLines/>' . single(84, 0) . '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' . $TAB . '"/></w:tabs><w:ind w:left="2160" w:right="864" w:hanging="720"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'ToaGroup', name => 'Toa Group', custom => 1,
    ppr => '<w:keepNext/>' . single(240, 60) . '<w:tabs><w:tab w:val="right" w:pos="' . $TAB . '"/></w:tabs><w:ind w:firstLine="0"/><w:jc w:val="left"/>', rpr => '<w:b/><w:bCs/>'),
  para_style(id => 'ToaEntry', name => 'Toa Entry', custom => 1,
    ppr => '<w:keepLines/>' . single(168, 0) . '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' . $TAB . '"/></w:tabs><w:ind w:left="504" w:hanging="504"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'SignatureClosing', name => 'Signature Closing', custom => 1,
    ppr => '<w:keepNext/><w:keepLines/>' . spacing(240, 528, $SGL) . '<w:ind w:left="4320" w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'SignatureBlock', name => 'Signature Block', custom => 1,
    ppr => '<w:keepLines/>' . single(0, 0) . '<w:ind w:left="4320" w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'SignatureBlockAlone', name => 'Signature Block Alone', custom => 1,   # no closing line: 1 em above (typst v(1em))
    ppr => '<w:keepLines/>' . single(240, 0) . '<w:ind w:left="4320" w:firstLine="0"/><w:jc w:val="left"/>', rpr => ''),
  para_style(id => 'CertificateBody', name => 'Certificate Body', custom => 1,
    ppr => spacing(0, 0, $DBL) . '<w:ind w:firstLine="720"/><w:jc w:val="left"/>', rpr => ''),
);

# replace the styles this template uses (pandoc's defaults carry colors, theme fonts and borders)
for my $id (qw(Normal BodyText FirstParagraph Compact BlockText FootnoteText Table Heading1 Heading2 Heading3 Heading4 Heading5)) {
  remove_style($id);
}
my $table = '<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:uiPriority w:val="59"/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:tblPr><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>';
add_style($table);
add_style($_) for @styles;
open my $out, '>:encoding(UTF-8)', $f or die "$f: $!";
print $out $s;
close $out;

# footer: centered PAGE field (cached result 1); the section properties decide the number format
my $ftr = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' . "\n"
  . '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
  . '<w:p><w:pPr><w:jc w:val="center"/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr>'
  . '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  . '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>';
open my $fo, '>:encoding(UTF-8)', "word/footer1.xml" or die;
print $fo $ftr;
close $fo;

my $rels = "word/_rels/document.xml.rels";
open my $ri, '<:encoding(UTF-8)', $rels or die;
my $r = <$ri>;
close $ri;
$r =~ s{</Relationships>}{<Relationship Id="rIdAfccaFooter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>} or die "no Relationships";
open my $ro, '>:encoding(UTF-8)', $rels or die;
print $ro $r;
close $ro;

my $ct = "[Content_Types].xml";
open my $ci, '<:encoding(UTF-8)', $ct or die;
my $c = <$ci>;
close $ci;
$c =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>} or die "no Types";
open my $co, '>:encoding(UTF-8)', $ct or die;
print $co $c;
close $co;

# body section: US Letter, 1 in margins, the footer, decimal numbering from 1
my $doc = "word/document.xml";
open my $di, '<:encoding(UTF-8)', $doc or die;
my $d = <$di>;
close $di;
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdAfccaFooter"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>';
$d =~ s{<w:sectPr\b.*</w:sectPr>}{$sect}s or die "no sectPr";
open my $do, '>:encoding(UTF-8)', $doc or die;
print $do $d;
close $do;
PL
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
