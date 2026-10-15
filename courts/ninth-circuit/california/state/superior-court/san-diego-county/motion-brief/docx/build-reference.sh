#!/bin/sh
# Builds docx/reference.docx for calsuperct-sandiego (complaint) from pandoc's default reference.docx.
# The grid is the one in typst/calsuperct-sandiego-complaint.typ (CRC 2.104-2.111, see ../README.md):
#   Liberation Serif 12 pt (CRC 2.104, 2.105); body lines exact 24 pt (double, CRC 2.108);
#   letter; top margin 1 in, bottom 46 pt (28 lines of 24 pt fit), left 1.5 in, right 0.5 in;
#   consecutive line numbers restarting on each page, 0.45 in left of the text (CRC 2.108);
#   a double rule left and a single rule right of the text (page borders, offset from the text);
#   footer: a printed rule, the page number (PAGE field), then the paper's title in 10 pt (CRC 2.110).
#   The footer title comes from the frontmatter: docx/render.sh replaces @@FOOTER_TITLE@@.
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, perl, unzip, zip, xmllint)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/ref.docx"

# styles.xml and document.xml: patched by perl (whitespace-tolerant; pandoc 3.12 writes multi-line XML).
cat > "$W/patch.pl" <<'PERL'
use strict;
use warnings;
my ($mode, $file) = @ARGV;
open(my $in, '<:encoding(UTF-8)', $file) or die "$file: $!";
my $x = do { local $/; <$in> };
close $in;

my $FONT = '<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif"/>';
my $SZ = '<w:sz w:val="24"/><w:szCs w:val="24"/>';
sub rpr {
  my %o = @_;
  my $s = $FONT;
  $s .= '<w:b/><w:bCs/>' if $o{b};
  $s .= '<w:i/><w:iCs/>' if $o{i};
  $s .= '<w:caps/>' if $o{caps};
  return $s . '<w:color w:val="000000"/>' . $SZ;
}
my $EXACT480 = 'w:before="0" w:after="0" w:line="480" w:lineRule="exact"';
my $EXACT240 = 'w:before="0" w:after="0" w:line="240" w:lineRule="exact"';
my $HEAD = 'w:before="240" w:after="240" w:line="480" w:lineRule="exact"';
my $JURY = 'w:before="480" w:after="240" w:line="480" w:lineRule="exact"';
my $FOOTNOTE = 'w:before="0" w:after="120" w:line="240" w:lineRule="auto"';

# [styleId, name, basedOn, default?, custom?, spacing, indent, jc, rPr]
my @STYLES = (
  ['Normal', 'Normal', '', 1, 0, $EXACT480, 'w:firstLine="0"', '', rpr()],
  ['BodyText', 'Body Text', 'Normal', 0, 0, $EXACT480, 'w:firstLine="720"', '', rpr()],
  ['FirstParagraph', 'First Paragraph', 'BodyText', 0, 1, $EXACT480, 'w:firstLine="720"', '', rpr()],
  ['Compact', 'Compact', 'BodyText', 0, 1, $EXACT480, 'w:firstLine="720"', '', rpr()],
  ['Heading1', 'heading 1', 'Normal', 0, 0, $HEAD, 'w:left="0" w:firstLine="0"', 'center', rpr(b => 1, caps => 1)],
  ['Heading2', 'heading 2', 'Normal', 0, 0, $HEAD, 'w:left="0" w:firstLine="0"', 'center', rpr(b => 1, caps => 1)],
  ['Heading3', 'heading 3', 'Normal', 0, 0, $HEAD, 'w:left="0" w:firstLine="0"', '', rpr(b => 1)],
  ['Heading4', 'heading 4', 'Normal', 0, 0, $HEAD, 'w:left="0" w:firstLine="0"', '', rpr(b => 1, i => 1)],
  ['FootnoteText', 'footnote text', 'Normal', 0, 0, $FOOTNOTE, 'w:firstLine="0"', '', rpr()],
  ['Single', 'Single', 'Normal', 0, 1, $EXACT240, 'w:firstLine="0"', '', rpr()],
  ['SigBlock', 'Signature Block', 'Single', 0, 1, $EXACT240, 'w:left="4464" w:firstLine="0"', '', rpr()],
  ['SigName', 'Signature Name', 'Single', 0, 1, $EXACT240, 'w:left="4896" w:firstLine="0"', '', rpr(b => 1, caps => 1)],
  ['SigRole', 'Signature Role', 'Single', 0, 1, $EXACT240, 'w:left="4896" w:firstLine="0"', '', rpr()],
  ['CourtTitle', 'Court Title', 'Normal', 0, 1, $EXACT480, 'w:firstLine="0"', 'center', rpr(b => 1)],
  ['CaptionTitle', 'Caption Title', 'Single', 0, 1, $EXACT240, 'w:firstLine="0"', '', rpr(b => 1)],
  ['FeeLabel', 'Fee Label', 'Single', 0, 1, $EXACT240, 'w:firstLine="0"', 'right', rpr()],
  ['JuryDemand', 'Jury Demand', 'Normal', 0, 1, $JURY, 'w:firstLine="0"', 'center', rpr(b => 1, caps => 1)],
);

if ($mode eq 'styles') {
  $x =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$FONT$SZ<w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s
    or die "no docDefaults";
  my $new = '';
  for my $s (@STYLES) {
    my ($id, $name, $based, $default, $custom, $sp, $ind, $jc, $rp) = @$s;
    $x =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
    my $attr = ($default ? ' w:default="1"' : '') . ($custom ? ' w:customStyle="1"' : '');
    my $based_el = $based ? qq{<w:basedOn w:val="$based"/>} : '';
    my $ppr = qq{<w:pPr>} . ($id =~ /^Heading/ ? '<w:keepNext/><w:keepLines/>' : '')
      . qq{<w:spacing $sp/><w:ind $ind/>} . ($jc ? qq{<w:jc w:val="$jc"/>} : '') . qq{</w:pPr>};
    $new .= qq{<w:style w:type="paragraph"$attr w:styleId="$id"><w:name w:val="$name"/>$based_el<w:qFormat/>$ppr<w:rPr>$rp</w:rPr></w:style>};
  }
  $x =~ s{</w:styles>}{$new</w:styles>} or die "no </w:styles>";
} elsif ($mode eq 'document') {
  my $sect = '<w:sectPr>'
    . '<w:footerReference w:type="default" r:id="rId100"/>'
    . '<w:pgSz w:w="12240" w:h="15840"/>'
    . '<w:pgMar w:top="1440" w:right="720" w:bottom="920" w:left="2160" w:header="720" w:footer="280" w:gutter="0"/>'
    . '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="18" w:color="000000"/>'
    . '<w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders>'
    . '<w:lnNumType w:countBy="1" w:distance="648" w:restart="newPage"/>'
    . '<w:cols w:space="720"/>'
    . '</w:sectPr>';
  if ($x =~ m{<w:sectPr\b.*?</w:sectPr>}s) {
    $x =~ s{<w:sectPr\b.*?</w:sectPr>}{$sect}s;
  } else {
    $x =~ s{</w:body>}{$sect</w:body>} or die "no </w:body>";
  }
} else {
  die "unknown mode $mode";
}

open(my $out, '>:encoding(UTF-8)', $file) or die "$file: $!";
print $out $x;
close $out;
PERL
perl "$W/patch.pl" styles word/styles.xml
perl "$W/patch.pl" document word/document.xml

# footer: printed rule, page number (PAGE field, cached 1), then the title in 10 pt
FONT='<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif"/>'
RPR="<w:rPr>$FONT<w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>"
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r>$RPR<w:fldChar w:fldCharType="begin"/></w:r><w:r>$RPR<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>$RPR<w:fldChar w:fldCharType="separate"/></w:r><w:r>$RPR<w:t>1</w:t></w:r><w:r>$RPR<w:fldChar w:fldCharType="end"/></w:r></w:p><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="220" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr>$FONT<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t xml:space="preserve">@@FOOTER_TITLE@@</w:t></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# every XML part must be well formed
find . -type f \( -name '*.xml' -o -name '*.rels' \) > "$W/parts"
while IFS= read -r part; do
  xmllint --noout "$part" || exit 1
done < "$W/parts"

case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
