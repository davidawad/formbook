#!/bin/sh
# Builds docx/reference.docx for the E.D. Va. Bankruptcy adversary complaint (vaeb) from pandoc's default
# reference.docx (docs/DOCX.md). The form is the one typst/vaeb-adversary-complaint.typ encodes: EB Garamond 12 pt;
# double spacing as an exact 24 pt line pitch, single as an exact 13.8 pt pitch; first-line indent 0.5 in; letter
# size, 1.5 in top margin (LBR 5005-1(C)(3)), 1 in other margins; level 1 headings centered bold capitals, level 2
# centered bold, level 3 bold italic; a centered PAGE number in the footer; tables with 0.5 pt rules.
# No line numbering: this court does not use pleading paper.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
unzip -q "$W/ref.docx" -d "$W/pkg"
cd "$W/pkg"
cat > "$W/edit.pl" <<'PERL'
use strict;
use warnings;
# $ARGV[0]: alignment of level 2 headings (center for the complaint)
my $h2jc = shift @ARGV;
sub slurp { my $f = shift; local $/; open my $h, '<:encoding(UTF-8)', $f or die "$f: $!"; my $s = <$h>; close $h; return $s; }
sub spit { my ($f, $s) = @_; open my $h, '>:encoding(UTF-8)', $f or die "$f: $!"; print $h $s; close $h; }
my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $BLACK = '<w:color w:val="000000"/>';
my $s = slurp('word/styles.xml');
$s =~ s{<w:rPrDefault>.*?</w:rPrDefault>}{<w:rPrDefault><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>}s or die "rPrDefault\n";
$s =~ s{<w:pPrDefault>.*?</w:pPrDefault>}{<w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:pPrDefault>}s or die "pPrDefault\n";
# put_style: replace the style with this styleId, or add it
sub put_style {
  my ($id, $xml) = @_;
  return if $s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$xml}s;
  $s =~ s{</w:styles>}{$xml</w:styles>} or die "no </w:styles>\n";
}
my $DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>';
put_style('BodyText', qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:widowControl/>$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>});
put_style('Compact', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>});
my $HEAD = qq{<w:keepNext/><w:keepLines/><w:widowControl/>};
put_style('Heading1', qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr>$HEAD<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$FONT<w:b/><w:bCs/><w:caps/>$BLACK<w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>});
put_style('Heading2', qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$HEAD<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="$h2jc"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$FONT<w:b/><w:bCs/>$BLACK<w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>});
put_style('Heading3', qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$HEAD<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$FONT<w:b/><w:bCs/><w:i/><w:iCs/>$BLACK<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>});
put_style('FootnoteText', qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine="0"/></w:pPr><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>});
# custom styles: single-spaced blocks (counsel, court, caption, signature, service list), centered single, the
# lettered (a), (b) items of a list, and the numbered paragraphs (number, then a tab to 1.0 in)
put_style('Single', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>});
put_style('Centered', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>});
put_style('Lettered', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$DOUBLE<w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/></w:pPr></w:style>});
put_style('Numbered', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Numbered"><w:name w:val="Numbered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1224"/></w:tabs></w:pPr></w:style>});
put_style('Closing', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Closing"><w:name w:val="Closing"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>});
# table style: 0.5 pt rules on every cell edge, 5 pt insets, indented 0.5 in (typst: stroke 0.5pt, inset 5pt)
my $RULE = '<w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/>';
put_style('Table', qq{<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="39"/><w:tblPr><w:tblInd w:w="720" w:type="dxa"/><w:tblBorders>$RULE</w:tblBorders><w:tblCellMar><w:top w:w="100" w:type="dxa"/><w:left w:w="100" w:type="dxa"/><w:bottom w:w="100" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>});
spit('word/styles.xml', $s);
# body section: letter, 1.5 in top margin, 1 in other margins, the page-number footer
my $d = slurp('word/document.xml');
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdVaebFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
$d =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s or die "sectPr\n";
spit('word/document.xml', $d);
my $r = slurp('word/_rels/document.xml.rels');
$r =~ s{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdVaebFooter1" Target="footer1.xml" /></Relationships>} or die "rels\n";
spit('word/_rels/document.xml.rels', $r);
my $c = slurp('[Content_Types].xml');
$c =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>} or die "types\n";
spit('[Content_Types].xml', $c);
PERL
perl "$W/edit.pl" center
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
