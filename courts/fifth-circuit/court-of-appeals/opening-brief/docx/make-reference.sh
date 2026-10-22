#!/bin/sh
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh: Times New Roman 14 pt, Body Text in 30.8 pt line boxes with a half-inch indent,
# footnotes 12 pt in 14 pt boxes with 7 pt between them, block quotations single-spaced (17 pt boxes) 0.5 in in from
# both margins with 14 pt above and below; typst pitch-double, pitch-single, pitch-note), plus the "CA5 ..."
# paragraph styles ca5-docx.lua writes the cover, headings, tables, signature and certificates in (twips = 20 x pt,
# the typst template's numbers). Page setup and the footers are NOT taken from here: pandoc does not carry a
# reference's section properties into its output, so docx/render.sh writes them.
# Usage: sh docx/make-reference.sh [out.docx]    (needs pandoc, unzip, zip, perl, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="Times New Roman" size=28 body=616 \
  single=340 indent=720 note=280 note_size=24 quote=280 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/styles.pl" <<'PL'
# Appends the court's own styles to word/styles.xml.
my ($file) = @ARGV;
open my $fh, '<:encoding(UTF-8)', $file or die "styles: $!";
local $/; my $s = <$fh>; close $fh;
sub sp { my ($b, $a, $l) = @_; $l //= 340; qq{<w:spacing w:before="$b" w:after="$a" w:line="$l" w:lineRule="exact"/>} }
my @st;
sub style {   # style(id, name, basedOn, pPr, rPr)
  my ($id, $name, $based, $ppr, $rpr) = @_;
  my $b = $based ? qq{<w:basedOn w:val="$based"/>} : '';
  push @st, qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
}
# body paragraphs: typst indents a first line only after another paragraph
style('CA5NoIndent', 'CA5 No Indent', 'BodyText', '<w:ind w:firstLine="0"/>', '');
# the brief's last paragraph stays whole and with the signature block
style('CA5BodyLast', 'CA5 Body Last', 'BodyText', '<w:keepNext/><w:keepLines/><w:ind w:firstLine="0"/>', '');
# section titles [heading level 1]: centered bold capitals, 16 pt, 28 pt above and 12.6 pt below
style('CA5Title', 'CA5 Title', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(560, 252) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>', '<w:b/><w:bCs/><w:caps/><w:sz w:val="32"/><w:szCs w:val="32"/>');
# front tables' titles [table-title]: the same, 16.8 pt below
style('CA5TableTitle', 'CA5 Table Title', 'CA5Title', sp(0, 336), '');
# sub-headings [sub-heading], levels 2 to 5: 28 pt above; the label in a 0.6 in box, the text hanging after it;
# each level steps in 0.5 in
for my $l (2..5) {
  my $ind = ($l - 2) * 720 + 864;
  my $after = $l == 2 ? 252 : 224;
  style("CA5Sub$l", "CA5 Sub $l", 'Normal', qq{<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="$ind"/></w:tabs>} . sp(560, $after) . qq{<w:ind w:left="$ind" w:hanging="864"/><w:outlineLvl w:val="} . ($l - 1) . q{"/>}, '');
}
# single-spaced lines: centered (cover), left (date, tables), the signature 3 in from the margin
style('CA5Centered', 'CA5 Centered', 'Normal', sp(0, 0) . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', '');
style('CA5Single', 'CA5 Single', 'Normal', sp(0, 0) . '<w:ind w:firstLine="0"/>', '');
style('CA5Signature', 'CA5 Signature', 'Normal', '<w:keepNext/><w:keepLines/>' . sp(0, 0) . '<w:ind w:left="4320" w:firstLine="0"/>', '');
# the certificate of interested persons: single-spaced, 7 pt between paragraphs
style('CA5Cip', 'CA5 CIP', 'Normal', sp(140, 0) . '<w:ind w:firstLine="720"/>', '');
style('CA5CipNoIndent', 'CA5 CIP No Indent', 'CA5Cip', '<w:ind w:firstLine="0"/>', '');
# widows and orphans are allowed, as in the typst template (its widow control leaves a moved line's footnote behind)
$s =~ s{<w:widowControl/>}{<w:widowControl w:val="0"/>}g or die "styles: no widow control to turn off";
my $add = join('', @st);
$s =~ s{</w:styles>}{$add</w:styles>} or die "styles: no end tag";
open my $out, '>:encoding(UTF-8)', $file or die "styles: $!";
print $out $s; close $out;
PL
perl "$W/styles.pl" word/styles.xml
xmllint --noout word/styles.xml
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
