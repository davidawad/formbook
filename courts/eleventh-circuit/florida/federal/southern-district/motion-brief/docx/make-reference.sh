#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (pandoc 3.6), in the form of
# typst/flsd-motion-brief.typ: EB Garamond 12 pt (L.R. 5.1(a)(4)); body text at exact 27.6 pt (double, the
# exemplar's pitch; the rule's floor is 1 1/2 spaces) with a 0.5 in first-line indent; single-spaced caption,
# signature, certificate and footnotes at exact 13.8 pt; Heading 1 centered bold capitals, Heading 2 bold at
# the left, Heading 3 bold at the left, indented 0.5 in; letter page with 1 in margins; footer 0.3 in from the
# bottom edge with the page number centered (PAGE field, cached result 1). Theme fonts are replaced: Word lets
# a theme font override a named one.
# Usage: sh docx/make-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl and xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/build.pl" <<'PL'
use strict;
use warnings;
local $/;
my $FONT = 'EB Garamond';
my $H2_JC = 'left';
my $RF = qq{<w:rFonts w:ascii="$FONT" w:hAnsi="$FONT" w:eastAsia="$FONT" w:cs="$FONT"/>};
my $BODY = q{<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/>};
my $SGL = q{<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>};
my $GAP_LG = q{<w:spacing w:before="0" w:after="0" w:line="1104" w:lineRule="exact"/>};
my $IND1 = q{<w:ind w:firstLine="720"/>};
my $NOIND = q{<w:ind w:firstLine="0"/>};
my $KEEP = q{<w:keepNext/><w:keepLines/>};
my $RUN = qq{<w:rPr>$RF<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>};
my $BOLD = qq{<w:rPr>$RF<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>};
my $H_SPACE = q{<w:spacing w:before="552" w:after="0" w:line="552" w:lineRule="exact"/>};

open my $in, '<:encoding(UTF-8)', 'word/styles.xml' or die "styles.xml: $!";
my $s = <$in>;
close $in;

# every font reference names the court font
$s =~ s{<w:rFonts\b[^>]*/>}{$RF}g;
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$RF<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s or die "no docDefaults";

sub put_style {
  my ($id, $xml) = @_;
  return if $s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$xml}s;
  $s =~ s{</w:styles>}{$xml</w:styles>} or die "no </w:styles>";
}
sub custom {
  my ($id, $name, $ppr) = @_;
  return qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$ppr</w:pPr>$RUN</w:style>};
}

put_style('Normal', qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$BODY$IND1</w:pPr>$RUN</w:style>});
put_style('BodyText', qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$BODY$IND1</w:pPr></w:style>});
put_style('FirstParagraph', qq{<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>$BODY$IND1</w:pPr></w:style>});
put_style('Compact', qq{<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$BODY$NOIND</w:pPr></w:style>});
put_style('Heading1', qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr>$KEEP$H_SPACE$NOIND<w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr>$BOLD</w:style>});
put_style('Heading2', qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$KEEP$H_SPACE$NOIND<w:jc w:val="$H2_JC"/><w:outlineLvl w:val="1"/></w:pPr>$BOLD</w:style>});
put_style('Heading3', qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$KEEP$H_SPACE<w:ind w:left="720" w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr>$BOLD</w:style>});
put_style('FootnoteText', qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>$NOIND</w:pPr>$RUN</w:style>});
put_style('Centered', custom('Centered', 'Centered', $SGL . $NOIND . q{<w:jc w:val="center"/>}));
put_style('CenteredKeep', custom('CenteredKeep', 'Centered Keep', $KEEP . $SGL . $NOIND . q{<w:jc w:val="center"/>}));
put_style('Single', custom('Single', 'Single', $SGL . $NOIND));
put_style('SingleKeep', custom('SingleKeep', 'Single Keep', $KEEP . $SGL . $NOIND));
put_style('CaptionLine', custom('CaptionLine', 'Caption Line', $SGL . q{<w:ind w:right="4680" w:firstLine="0"/>}));
put_style('SigLine', custom('SigLine', 'Signature Line', $KEEP . $SGL . q{<w:ind w:left="5040" w:firstLine="0"/>}));
put_style('BodyKeep', custom('BodyKeep', 'Body Keep', $KEEP . $BODY . $IND1));
put_style('GapSmall', custom('GapSmall', 'Gap Small', $KEEP . $BODY . $NOIND));
put_style('GapLarge', custom('GapLarge', 'Gap Large', $KEEP . $GAP_LG . $NOIND));
put_style('GapPlain', custom('GapPlain', 'Gap Plain', $BODY . $NOIND));
put_style('SigLast', custom('SigLast', 'Signature Line Last', $SGL . q{<w:ind w:left="5040" w:firstLine="0"/>}));

open my $out, '>:encoding(UTF-8)', 'word/styles.xml' or die "styles.xml: $!";
print $out $s;
close $out;

# footer: the page number, centered
open my $ftr, '>:encoding(UTF-8)', 'word/footer1.xml' or die "footer1.xml: $!";
print $ftr q{<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
};
close $ftr;

open my $rels, '<:encoding(UTF-8)', 'word/_rels/document.xml.rels' or die "rels: $!";
my $r = <$rels>;
close $rels;
$r =~ s{</Relationships>}{<Relationship Id="rIdFtrPage1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>} or die "no </Relationships>";
open my $rels_out, '>:encoding(UTF-8)', 'word/_rels/document.xml.rels' or die "rels: $!";
print $rels_out $r;
close $rels_out;

open my $ct, '<:encoding(UTF-8)', '[Content_Types].xml' or die "content types: $!";
my $c = <$ct>;
close $ct;
$c =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>} or die "no </Types>";
open my $ct_out, '>:encoding(UTF-8)', '[Content_Types].xml' or die "content types: $!";
print $ct_out $c;
close $ct_out;

# body section: letter, 1 in margins, footer 0.3 in from the edge
my $SECT = q{<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrPage1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0"/></w:sectPr>};
open my $doc, '<:encoding(UTF-8)', 'word/document.xml' or die "document.xml: $!";
my $d = <$doc>;
close $doc;
if ($d =~ s{<w:sectPr\b.*?</w:sectPr>}{$SECT}s) {
} else {
  $d =~ s{</w:body>}{$SECT</w:body>} or die "no </w:body>";
}
open my $doc_out, '>:encoding(UTF-8)', 'word/document.xml' or die "document.xml: $!";
print $doc_out $d;
close $doc_out;
PL
perl "$W/build.pl"
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$part"
done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
