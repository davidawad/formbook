#!/bin/sh
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh: Times New Roman 14 pt everywhere, Body Text in 25.9 pt line boxes with a half-inch
# indent, footnotes 14 pt in 16 pt boxes, exact line spacing; typst pitch-double, pitch-single), plus the "CA ..."
# paragraph styles ca4.lua writes the cover, headings, tables and certificates in: single-spaced (16 pt boxes), with
# the typst template's spaces (twips = 20 x pt). Page setup and the footers are NOT taken from here: pandoc does not
# carry a reference's section properties into its output, so docx/render.sh writes them.
# Usage: sh docx/build-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
# The same file in the three doc-type folders except for ITAL (typst style-heading).
set -eu
ITAL=4         # numbered heading levels from this one are bold italic, label included (typst style-heading)
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="Times New Roman" size=28 body=518 \
  single=320 indent=720 note=320 note_after=140 quote=280 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/styles.pl" <<'PL'
# Appends the court's own styles to word/styles.xml.
my ($file) = @ARGV;
my $ITAL = $ENV{ITAL};
my $TEXTW = 9360;   # 6.5 in, the text width (letter, 1 in margins)
my $PCOL = 720;     # the contents' page column (typst toc-page-col, 36 pt)
my $ACOL = 1120;    # the authorities' page column (typst toa-page-col, 56 pt)
my $HALF = 4680;    # the right half of the text width (typst right-half)
open my $fh, '<:encoding(UTF-8)', $file or die "styles: $!";
local $/; my $s = <$fh>; close $fh;
sub sp { my ($b, $a) = @_; qq{<w:spacing w:before="$b" w:after="$a" w:line="320" w:lineRule="exact"/>} }
my @st;
sub style {   # style(id, name, basedOn, pPr, rPr)
  my ($id, $name, $based, $ppr, $rpr) = @_;
  my $b = $based ? qq{<w:basedOn w:val="$based"/>} : '';
  push @st, qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
}
style('CABodyLast', 'CA Body Last', 'BodyText', '<w:keepNext/><w:keepLines/>', '');
# section headings: 21 pt above, 15.4 pt below, centered bold capitals (the answering and reply briefs: 16 pt type in
# a 16 pt box); unnumbered sub-headings 16.8 / 12.6 pt, bold at the margin; numbered ones 15.4 / 12.6 pt, the label
# at S half-inches, the text hanging a half inch more; a centered point heading 16.8 / 14 pt
style('CASection', 'CA Section', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(420, 308) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>', '<w:b/><w:caps/>');
style('CASectionBig', 'CA Section Big', 'CASection', '', '<w:sz w:val="32"/><w:szCs w:val="32"/>');
style('CAUnnum', 'CA Unnumbered', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(336, 252) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/>', '<w:b/>');
style('CAPoint', 'CA Point', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(336, 280) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>', '<w:b/>');
for my $l (2..5) { for my $sx (0..4) {
  my $ind = ($sx + 1) * 720;
  my $i = $l >= $ITAL ? '<w:i/>' : '';
  style("CAHeadL${l}S$sx", "CA Heading L${l} S$sx", 'Normal',
    qq{<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="$ind"/></w:tabs>} . sp(308, 252) . qq{<w:ind w:left="$ind" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="}.($l-1).q{"/>},
    qq{<w:b/>$i});
} }
style('CACentered', 'CA Centered', 'Normal', sp(0, 98) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', '');
style('CAGap', 'CA Gap', 'Normal', '<w:spacing w:before="0" w:after="0" w:line="140" w:lineRule="exact"/>', '');
style('CARule', 'CA Rule', 'Normal', '<w:keepNext/><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="100" w:line="120" w:lineRule="exact"/><w:ind w:left="3240" w:right="3240" w:firstLine="0"/><w:jc w:val="center"/>', '');
style('CADoubleRule', 'CA Double Rule', 'Normal', '<w:keepNext/><w:pBdr><w:top w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="120" w:line="120" w:lineRule="exact"/><w:ind w:firstLine="0"/>', '');
style('CACaption', 'CA Caption', 'Normal', '<w:keepLines/>' . sp(0, 98) . qq{<w:ind w:left="$HALF" w:firstLine="0"/><w:jc w:val="left"/>}, '');
style('CACounsel', 'CA Counsel', 'Normal', sp(0, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/>', '');
style('CASignature', 'CA Signature', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(0, 0) . qq{<w:ind w:left="$HALF" w:firstLine="0"/><w:jc w:val="left"/>}, '');
style('CASigHead', 'CA Signature Head', 'CASignature', sp(392, 0), '');
style('CACertificate', 'CA Certificate', 'Normal', sp(280, 280) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/>', '');
# contents rows (typst listing-row): the text wraps before the page column (right indent), a dot leader runs to a
# right tab at the margin, beyond the indent; the text hangs a half inch past the row's indent
my $rt = $TEXTW;
style('CATocTop', 'CA TOC 1', 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$rt"/></w:tabs>} . sp(168, 0) . qq{<w:ind w:left="720" w:right="$PCOL" w:hanging="720"/>}, '');
for my $sx (0..4) { my $ind = ($sx + 1) * 720;
  style("CATocS$sx", "CA TOC Entry S$sx", 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="left" w:leader="none" w:pos="$ind"/><w:tab w:val="right" w:leader="dot" w:pos="$rt"/></w:tabs>} . sp(98, 0) . qq{<w:ind w:left="$ind" w:right="$PCOL" w:hanging="720"/>}, ''); }
style('CATocPage', 'CA TOC Page', 'Normal', '<w:keepNext/>' . sp(84, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="right"/>', '<w:b/><w:u w:val="single"/>');
style('CAToaGroup', 'CA TOA Group', 'Normal', qq{<w:keepNext/><w:tabs><w:tab w:val="right" w:pos="$TEXTW"/></w:tabs>} . sp(392, 56) . '<w:ind w:firstLine="0"/>', '<w:b/>');
style('CAToaEntry', 'CA TOA Entry', 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$TEXTW"/></w:tabs>} . sp(140, 0) . qq{<w:ind w:left="504" w:right="$ACOL" w:hanging="504"/>}, '');
my $add = join('', @st);
$s =~ s{</w:styles>}{$add</w:styles>} or die "styles: no end tag";
open my $out, '>:encoding(UTF-8)', $file or die "styles: $!";
print $out $s; close $out;
PL
ITAL=$ITAL perl "$W/styles.pl" word/styles.xml
xmllint --noout word/styles.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
