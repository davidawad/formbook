#!/bin/sh
# Builds docx/reference.docx for the BAP 8th Cir. brief (FRBP 8015): the shared style recipe of the cross-engine layout
# model (lib/docx/xengine-reference.sh: Times New Roman 14 pt (FRBP 8015(a)(5)(A)), Body Text in 32.2 pt line boxes
# with a half-inch first-line indent (double spacing, FRBP 8015(a)(4); typst line-pitch), quotations and footnotes
# 14 pt in 16.1 pt boxes (typst pitch-single), exact line spacing, widow control, 1 in margins on US Letter), plus the
# paragraph styles front.jq and brief.lua write the cover, front matter, headings, tables and certificates in, with the
# typst template's pitches and spaces (twips = 20 x pt). The footer (a centered PAGE field) carries the id rIdBapFooter
# the front matter's sections name; the body section numbers its pages from 1.
# Usage: sh docx/build-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -eu
FONT="Times New Roman"
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="$FONT" size=28 body=644 single=322 \
  indent=720 heading=368 quote=280 note_after=140 footer=720 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/styles.pl" <<'PL'
# Appends the court's own styles to word/styles.xml (typst bap8-*.typ: pitches 32.2 / 16.1 / 18.4 pt).
my ($file) = @ARGV;
my $TEXTW = 9360;   # 6.5 in, the text width (letter, 1 in margins)
my $PCOL = 720;     # the contents' page column (typst toc-page-col, 36 pt)
my $ACOL = 1120;    # the authorities' page column (typst toa-page-col, 56 pt; brief.lua widens it for a longer list)
open my $fh, '<:encoding(UTF-8)', $file or die "styles: $!";
local $/; my $s = <$fh>; close $fh;
sub sp { my ($b, $a, $l) = @_; $l //= 322; qq{<w:spacing w:before="$b" w:after="$a" w:line="$l" w:lineRule="exact"/>} }
my @st;
sub style {   # style(id, name, basedOn, pPr, rPr)
  my ($id, $name, $based, $ppr, $rpr) = @_;
  my $b = $based ? qq{<w:basedOn w:val="$based"/>} : '';
  push @st, qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
}
my $L = '<w:ind w:firstLine="0"/><w:jc w:val="left"/>';
# the last body paragraph stays with the signature block (typst: block(breakable: false))
style('BodyKeep', 'Body Keep', 'BodyText', '<w:keepNext/><w:keepLines/>', '');
# cover: single-spaced, centered or from the middle of the line
style('CoverCenter', 'Cover Center', 'Normal', sp(0, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', '');
style('CoverIndent', 'Cover Indent', 'Normal', sp(0, 0) . '<w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/>', '');
style('CoverStep', 'Cover Step', 'CoverIndent', '<w:ind w:left="4820" w:firstLine="0"/>', '');   # counsel lines, 0.5 em in
style('CoverGap', 'Cover Gap', 'Normal', '<w:spacing w:before="0" w:after="0" w:line="200" w:lineRule="exact"/><w:jc w:val="center"/>', '');
style('DoubleRule', 'Double Rule', 'Normal', '<w:pBdr><w:bottom w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>', '<w:sz w:val="8"/><w:szCs w:val="8"/>');
style('ShortRule', 'Short Rule', 'Normal', '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr>' . sp(0, 240, 80) . '<w:ind w:left="3240" w:right="3240" w:firstLine="0"/><w:jc w:val="center"/>', '');
# front matter and certificates: paragraphs 14 pt apart (typst par spacing 1em)
style('Single', 'Single', 'Normal', sp(0, 280) . $L, '');
style('BulletItem', 'Bullet Item', 'Normal', '<w:keepLines/>' . sp(0, 0) . '<w:ind w:left="360" w:hanging="360"/><w:jc w:val="left"/>', '');
# a certificate's check-box row: the box half an inch in, the text in a 1.6 em column after it (typst box-row)
style('CertBox', 'Certificate Box', 'Normal', '<w:keepLines/>' . sp(224, 224) . '<w:ind w:left="1168" w:hanging="448"/><w:jc w:val="left"/>', '');
# signature block (typst signature-block, form-sig-line): from the middle of the line
my $SIG = '<w:keepNext/><w:keepLines/>';
style('Signature', 'Signature', 'Normal', $SIG . sp(0, 0) . '<w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/>', '');
style('SigHead', 'Signature Head', 'Signature', sp(392, 0), '');
style('SigName', 'Signature Name', 'Signature', sp(336, 0), '');
style('SigLines', 'Signature Lines', 'Signature', '<w:ind w:left="4820" w:firstLine="0"/>', '<w:i/><w:iCs/>');
style('SigDate', 'Signature Date', 'Normal', sp(224, 0) . $L, '');
style('FormSig', 'Form Signature', 'Signature', '<w:keepNext w:val="0"/>' . sp(448, 0), '');
# headings: a section heading 16 pt bold capitals in an 18.4 pt box, 21 pt above, 15.4 pt below (none above at the top
# of a page); point headings 16.8 / 14 pt; sub-headings 15.4 / 12.6 pt, the label at its step, the text a half inch on
my $HEAD = '<w:keepNext/><w:keepLines/>';
style('FrontHeading', 'Front Heading', 'Normal', $HEAD . sp(0, 308, 368) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', '<w:b/><w:bCs/><w:caps/><w:sz w:val="32"/><w:szCs w:val="32"/>');
style('SectionHeading', 'Section Heading', 'FrontHeading', sp(420, 308, 368) . '<w:outlineLvl w:val="0"/>', '');
style('SectionHeadingTop', 'Section Heading Top', 'FrontHeading', sp(0, 308, 368) . '<w:outlineLvl w:val="0"/>', '');
style('PointHeading', 'Point Heading', 'Normal', $HEAD . sp(336, 280) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>', '<w:b/><w:bCs/>');
for my $spec ("Sub2:1440:1", "Sub3:2160:2", "Sub4:2880:3", "Sub5:3600:4", "ArgSub3:1440:2", "ArgSub4:2160:3", "ArgSub5:2880:4") {
  my ($id, $left, $lvl) = split /:/, $spec;
  my $it = $lvl >= 3 ? '<w:i/><w:iCs/>' : '';
  style($id, $id, 'Normal', $HEAD . sp(308, 252) . qq{<w:ind w:left="$left" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="$lvl"/>}, "<w:b/><w:bCs/>$it");
}
# contents rows (typst listing-row): the text wraps before the page column (right indent), the label at its step, a dot
# leader runs to a right tab at the margin, beyond the indent
for my $spec ("TOC1:720:168", "TOCArg:720:98", "TOC2:1440:98", "TOC3:2160:98", "TOC4:2880:98", "TOC5:3600:98") {
  my ($id, $left, $before) = split /:/, $spec;
  style($id, $id, 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$TEXTW"/></w:tabs>} . sp($before, 0) . qq{<w:ind w:left="$left" w:right="$PCOL" w:hanging="720"/><w:jc w:val="left"/>}, '');
}
style('PageLabel', 'Page Label', 'Normal', '<w:keepNext/>' . sp(84, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="right"/>', '');
style('TOAGroup', 'TOA Group', 'Normal', qq{<w:keepNext/><w:tabs><w:tab w:val="right" w:pos="$TEXTW"/></w:tabs>} . sp(392, 56) . '<w:ind w:firstLine="0"/>', '<w:b/><w:bCs/>');
style('TOAGroupFirst', 'TOA Group First', 'TOAGroup', sp(280, 56), '');
style('TOAEntry', 'TOA Entry', 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$TEXTW"/></w:tabs>} . sp(196, 0) . qq{<w:ind w:left="504" w:right="$ACOL" w:hanging="504"/><w:jc w:val="left"/>}, '');
style('ServiceAddress', 'Service Address', 'Normal', '<w:keepLines/>' . sp(196, 0) . '<w:ind w:left="720" w:firstLine="0"/><w:jc w:val="left"/>', '');
my $add = join('', @st);
$s =~ s{</w:styles>}{$add</w:styles>} or die "styles: no end tag";
open my $out, '>:encoding(UTF-8)', $file or die "styles: $!";
print $out $s; close $out;
PL
perl "$W/styles.pl" word/styles.xml
xmllint --noout word/styles.xml
# the footer under the id the front matter's sections name (front.jq); the body section counts from 1
perl -pi -e 's/rIdFooter1/rIdBapFooter/g' word/_rels/document.xml.rels word/document.xml
perl -0pi -e 's{(<w:pgMar [^>]*/>)}{$1<w:pgNumType w:fmt="decimal" w:start="1"/>}s or die "pgMar"' word/document.xml
xmllint --noout word/document.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
