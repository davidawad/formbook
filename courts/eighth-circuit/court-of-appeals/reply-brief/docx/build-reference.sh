#!/usr/bin/env bash
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh: Gelasio 14 pt, Body Text in 28 pt line boxes with a half-inch indent,
# footnotes in 17 pt boxes, 7 pt after each, exact line spacing; typst pitch-double, pitch-single), plus the "CA ..."
# paragraph styles ca8.lua writes the cover, headings, tables, signature and certificates in: single-spaced (17 pt
# boxes), with the typst template's spaces (twips = 20 x pt). Page setup and the footers are NOT taken from here:
# pandoc does not carry a reference's section properties into its output, so docx/render.sh writes them.
# Usage: sh docx/build-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -euo pipefail
ITAL=99        # no heading style is italic: the filter sets the titles of levels 4 and 5 in italics, never the label
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d) || exit 1
# safe_rmdir <dir>: delete a directory made by mktemp -d (or one inside it), and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="Gelasio" size=28 body=560 \
  single=340 indent=720 note_after=140 quote=280 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/styles.pl" <<'PL'
# Appends the court's own styles to word/styles.xml.
my ($file) = @ARGV;
my $ITAL = $ENV{ITAL};
my $TEXTW = 9360;   # 6.5 in, the text width (letter, 1 in margins)
my $PCOL = 720;     # the contents' page column (typst toc-page-col, 36 pt)
my $ACOL = 1120;    # the authorities' page column (typst toa-page-col, 56 pt)
open my $fh, '<:encoding(UTF-8)', $file or die "styles: $!";
local $/; my $s = <$fh>; close $fh;
sub sp { my ($b, $a) = @_; qq{<w:spacing w:before="$b" w:after="$a" w:line="340" w:lineRule="exact"/>} }
my @st;
sub style {   # style(id, name, basedOn, pPr, rPr)
  my ($id, $name, $based, $ppr, $rpr) = @_;
  my $b = $based ? qq{<w:basedOn w:val="$based"/>} : '';
  push @st, qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
}
style('CABodyLast', 'CA Body Last', 'BodyText', '<w:keepNext/><w:keepLines/>', '');
# [style-heading]: section headings 21 pt above, 15.4 pt below; numbered headings
# 15.4 / 12.6 pt, the label at S half-inches, the text hanging a half inch more
style('CASection', 'CA Section', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(420, 308) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>', '<w:b/><w:caps/>');
for my $l (2..5) { for my $sx (0..4) {
  my $ind = ($sx + 1) * 720;
  my $i = $l >= $ITAL ? '<w:i/>' : '';
  style("CAHeadL${l}S$sx", "CA Heading L${l} S$sx", 'Normal',
    qq{<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="$ind"/></w:tabs>} . sp(308, 252) . qq{<w:ind w:left="$ind" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="}.($l-1).q{"/>},
    qq{<w:b/>$i});
} }
# [cover-body]: centered, single-spaced
style('CACentered', 'CA Centered', 'Normal', sp(0, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', '');
# single-spaced lines at the margin, or indented (cover counsel, signature, certificates)
style('CACounsel', 'CA Counsel', 'Normal', sp(0, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="left"/>', '');
# contents rows (typst listing-row): the text wraps before the page column (right indent), a dot leader runs to a
# right tab at the margin, beyond the indent; 8.4 pt above a section's row, 4.9 pt above the others
my $rt = $TEXTW;
style('CATocTop', 'CA TOC 1', 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="$rt"/></w:tabs>} . sp(168, 0) . qq{<w:ind w:left="720" w:right="$PCOL" w:hanging="720"/>}, '');
for my $sx (0..4) { my $ind = ($sx + 1) * 720;
  style("CATocS$sx", "CA TOC Entry S$sx", 'Normal', qq{<w:keepLines/><w:tabs><w:tab w:val="left" w:leader="none" w:pos="$ind"/><w:tab w:val="right" w:leader="dot" w:pos="$rt"/></w:tabs>} . sp(98, 0) . qq{<w:ind w:left="$ind" w:right="$PCOL" w:hanging="720"/>}, ''); }
# the underlined "Page" over the contents' page column, 4.2 pt below the heading
style('CATocPage', 'CA TOC Page', 'Normal', '<w:keepNext/>' . sp(84, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="right"/>', '<w:b/><w:u w:val="single"/>');
# [toa-section]: group heads 19.6 pt above (the first 14 pt, with "Page(s)" at a right tab), 2.8 pt below; entries
# 7 pt above, hanging 0.35 in
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
