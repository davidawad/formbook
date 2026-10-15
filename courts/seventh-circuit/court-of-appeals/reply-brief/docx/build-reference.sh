#!/bin/sh
# Builds docx/reference.docx: the paragraph and character styles the brief is written in (EB Garamond,
# exact double spacing, first-line indent, footnotes single-spaced, headings keep with next, widow control).
# Page setup and the footers are NOT taken from here: pandoc does not carry a reference's section properties
# into its output, so docx/render.sh writes the sections, the page-number footers and the page setup
# (see that script). Constants below are this court's (typst template parameters); the perl block builds the
# style XML. Usage: sh docx/build-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -eu
BODY=24        # body size, half-points (12 pt; Cir. R. 32(b))
FN=22          # footnote size, half-points (11 pt; Cir. R. 32(b))
PITCH=553      # exact line pitch, twips (26.94 pt: the typst body baseline pitch)
ITAL=4         # heading levels from this one are italic (typst style-heading)
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/styles.pl" <<'PL'
# Rewrites word/styles.xml: replaces the docDefaults and the styles this court uses, appends the court's own.
my ($file) = @ARGV;
my ($BODY, $FN, $PITCH, $ITAL) = ($ENV{BODY}, $ENV{FN}, $ENV{PITCH}, $ENV{ITAL});
my $TEXTW = 9360;   # 6.5 in, the text width (letter, 1 in margins)
my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
open my $fh, '<:encoding(UTF-8)', $file or die "styles: $!";
local $/; my $s = <$fh>; close $fh;
my @replace = qw(Normal BodyText FirstParagraph Compact BlockText FootnoteText Heading1 Heading2 Heading3 Heading4 Heading5);
for my $id (@replace) { $s =~ s{<w:style [^>]*w:styleId="$id"[^>]*>.*?</w:style>}{}s; }
my $defaults = qq{<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>};
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "styles: no docDefaults";
my $single = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>';
my @st;
sub style {   # style(type, id, name, basedOn, custom, pPr, rPr, extra)
  my ($id, $name, $based, $custom, $ppr, $rpr) = @_;
  my $c = $custom ? ' w:customStyle="1"' : '';
  my $b = $based ? qq{<w:basedOn w:val="$based"/>} : '';
  push @st, qq{<w:style w:type="paragraph"$c w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
}
style('Normal', 'Normal', '', 0, '<w:widowControl/>' . $single . '<w:ind w:firstLine="0"/>', '');
style('BodyText', 'Body Text', 'Normal', 0, qq{<w:widowControl/><w:spacing w:before="0" w:after="0" w:line="$PITCH" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/>}, '');
style('FirstParagraph', 'First Paragraph', 'BodyText', 0, '', '');
style('CABodyLast', 'CA Body Last', 'BodyText', 1, '<w:keepNext/>', '');
style('Compact', 'Compact', 'Normal', 0, '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>', '');
style('BlockText', 'Block Text', 'Normal', 0, '<w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/>', '');
style('FootnoteText', 'footnote text', 'Normal', 0, qq{<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>}, qq{<w:sz w:val="$FN"/><w:szCs w:val="$FN"/>});
style('Heading1', 'heading 1', 'Normal', 0, '<w:keepNext/><w:keepLines/><w:spacing w:before="300" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>', '<w:b/><w:caps/>');
for my $n (2..5) { style("Heading$n", "heading $n", 'Normal', 0, qq{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="}.($n-1).q{"/>}, '<w:b/>'); }
# custom styles: section headings, numbered headings (label at S half-inches, text hanging a half inch more)
style('CASection', 'CA Section', 'Normal', 1, '<w:keepNext/><w:keepLines/><w:spacing w:before="300" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>', '<w:b/><w:caps/>');
style('CAPoint', 'CA Point', 'Normal', 1, '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>', '<w:b/><w:smallCaps/>');
for my $l (2..5) { for my $sx (0..4) {
  my $ind = ($sx + 1) * 720;
  my $i = $l >= $ITAL ? '<w:i/>' : '';
  style("CAHeadL${l}S$sx", "CA Heading L${l} S$sx", 'Normal', 1,
    qq{<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="$ind"/></w:tabs><w:spacing w:before="240" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:left="$ind" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="}.($l-1).q{"/>},
    qq{<w:b/>$i});
} }
style('CACentered', 'CA Centered', 'Normal', 1, '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', '');
style('CACoverCourt', 'CA Cover Court', 'CACentered', 1, '<w:keepNext/><w:spacing w:before="60" w:after="60" w:line="240" w:lineRule="auto"/>', '<w:b/>');
style('CAGap', 'CA Gap', 'Normal', 1, '<w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/>', '');
style('CARule', 'CA Rule', 'Normal', 1, '<w:keepNext/><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:left="3240" w:right="3240" w:firstLine="0"/><w:jc w:val="center"/>', '');
style('CADoubleRule', 'CA Double Rule', 'Normal', 1, '<w:keepNext/><w:pBdr><w:top w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>', '');
style('CACaption', 'CA Caption', 'Normal', 1, '<w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/>', '');
style('CACounsel', 'CA Counsel', 'Normal', 1, '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>', '');
style('CASignature', 'CA Signature', 'Normal', 1, '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/>', '');
style('CASigHead', 'CA Signature Head', 'CASignature', 1, '<w:spacing w:before="360" w:after="0" w:line="240" w:lineRule="auto"/>', '');
style('CACertificate', 'CA Certificate', 'Normal', 1, '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>', '');
style('CATocTop', 'CA TOC 1', 'Normal', 1, qq{<w:keepNext/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$TEXTW"/></w:tabs><w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>}, '');
for my $sx (0..4) { my $ind = ($sx + 1) * 720;
  style("CATocS$sx", "CA TOC Entry S$sx", 'Normal', 1, qq{<w:keepLines/><w:tabs><w:tab w:val="left" w:leader="none" w:pos="$ind"/><w:tab w:val="right" w:leader="dot" w:pos="$TEXTW"/></w:tabs><w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="$ind" w:hanging="720"/>}, ''); }
style('CAToaGroup', 'CA TOA Group', 'Normal', 1, qq{<w:keepNext/><w:tabs><w:tab w:val="right" w:pos="$TEXTW"/></w:tabs><w:spacing w:before="160" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>}, '<w:b/>');
style('CAToaEntry', 'CA TOA Entry', 'Normal', 1, qq{<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$TEXTW"/></w:tabs><w:spacing w:before="60" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="504" w:right="720" w:hanging="504"/>}, '');
my $add = join('', @st);
$s =~ s{</w:styles>}{$add</w:styles>} or die "styles: no end tag";
open my $out, '>:encoding(UTF-8)', $file or die "styles: $!";
print $out $s; close $out;
PL
BODY=$BODY FN=$FN PITCH=$PITCH ITAL=$ITAL perl "$W/styles.pl" word/styles.xml
xmllint --noout word/styles.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
