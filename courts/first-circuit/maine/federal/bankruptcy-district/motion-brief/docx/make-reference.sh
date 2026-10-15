#!/bin/sh
# Build docx/reference.docx: pandoc's default reference with the D. Me. page setup and the styles of
# typst/meb-adversary-complaint.typ (run once; the output is checked in). Needs pandoc, unzip, zip, perl.
# Usage: sh docx/make-reference.sh <doc-type-dir>/docx
# Letter paper, 1 in margins; EB Garamond 12 pt; body lines exactly 24 pt (double), first line indent 0.5 in;
# headings bold black, no colour; "- n -" page number centred in the footer. Styles named "Pleading ..." are
# used by docx/meb-adversary-complaint.lua.
set -eu
D=$(cd "$1" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && unzip -q ref.docx -d x && cd x
cat > "$W/patch.pl" <<'PERL'
use strict;
use warnings;
my ($styles, $doc, $rels, $ct) = @ARGV;
my $xml = do { local $/; open my $fh, '<:encoding(UTF-8)', $styles or die; <$fh> };

sub style_xml {
  my ($id, $name, $custom, $based, $ppr, $rpr) = @_;
  my $c = $custom ? ' w:customStyle="1"' : '';
  my $b = $based ? qq{<w:basedOn w:val="$based"/>} : '';
  $ppr = $ppr ? "<w:pPr>$ppr</w:pPr>" : '';
  $rpr = $rpr ? "<w:rPr>$rpr</w:rPr>" : '';
  return qq{<w:style w:type="paragraph"$c w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/>$ppr$rpr</w:style>};
}
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $body12 = '<w:sz w:val="24"/><w:szCs w:val="24"/>';
my $double = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $single = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>';
my $tab1in = '<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>';

# Built-in styles pandoc uses for its own output: replaced whole, same styleIds.
my %builtin = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>$single</w:pPr><w:rPr>$font$body12</w:rPr></w:style>},
  BodyText => style_xml('BodyText', 'Body Text', 0, 'Normal', $double . '<w:ind w:firstLine="720"/>', ''),
  FirstParagraph => style_xml('FirstParagraph', 'First Paragraph', 0, 'BodyText', '', ''),
  Compact => style_xml('Compact', 'Compact', 0, 'BodyText', '', ''),
  Heading1 => style_xml('Heading1', 'heading 1', 0, 'Normal',
    '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>',
    '<w:b/><w:bCs/>' . $body12),
  Heading2 => style_xml('Heading2', 'heading 2', 0, 'Normal',
    '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:outlineLvl w:val="1"/>',
    '<w:b/><w:bCs/>' . $body12),
  Heading3 => style_xml('Heading3', 'heading 3', 0, 'Normal',
    '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:outlineLvl w:val="2"/>',
    '<w:b/><w:bCs/><w:i/><w:iCs/>' . $body12),
);
for my $id (sort keys %builtin) {
  $xml =~ s{<w:style [^>]*w:styleId="$id".*?</w:style>}{$builtin{$id}}s or die "reference: no style $id";
}

# The court's paragraph and layout styles (used by the Lua filter through custom-style).
my @custom = (
  style_xml('PleadingBody', 'Pleading Body', 1, 'Normal', $double . '<w:ind w:firstLine="720"/>', ''),
  style_xml('PleadingNumbered', 'Pleading Numbered', 1, 'PleadingBody', $tab1in, ''),
  style_xml('PleadingRelief', 'Pleading Relief', 1, 'PleadingBody', '<w:keepNext/><w:keepLines/>', ''),
  style_xml('PleadingList', 'Pleading List', 1, 'Normal', $tab1in . $double . '<w:ind w:left="1440" w:hanging="720"/>', ''),
  style_xml('PleadingGap', 'Pleading Gap', 1, 'Normal', $double, ''),
  style_xml('PleadingSingle', 'Pleading Single', 1, 'Normal', $single, ''),
  style_xml('PleadingCourt', 'Pleading Court', 1, 'PleadingSingle', '<w:keepNext/><w:jc w:val="center"/>', '<w:b/><w:bCs/>'),
  style_xml('PleadingLegend', 'Pleading Legend', 1, 'PleadingSingle', '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="right"/>', '<w:b/><w:bCs/>'),
  style_xml('PleadingTitle', 'Pleading Title', 1, 'PleadingSingle', '<w:keepNext/><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>', '<w:b/><w:bCs/>'),
  style_xml('PleadingSignature', 'Pleading Signature', 1, 'PleadingSingle', '<w:keepNext/><w:tabs><w:tab w:val="left" w:pos="4320"/></w:tabs><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/>', ''),
  style_xml('PleadingSignatureTight', 'Pleading Signature Tight', 1, 'PleadingSignature', '<w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/>', ''),
  style_xml('PleadingCertificateTitle', 'Pleading Certificate Title', 1, 'PleadingTitle', '<w:pageBreakBefore/>', ''),
  style_xml('PleadingSignatureLine', 'Pleading Signature Line', 1, 'PleadingSingle', '<w:keepNext/><w:ind w:left="4320"/>', ''),
  style_xml('PleadingSignatureLast', 'Pleading Signature Last', 1, 'PleadingSingle', '<w:ind w:left="4320"/>', ''),
);
$xml =~ s{</w:styles>}{join('', @custom) . '</w:styles>'}e or die 'reference: no </w:styles>';

# Theme fonts and colours go; every run takes the court face and 12 pt.
$xml =~ s{<w:rFonts[^>]*/>}{$font}g;
$xml =~ s{<w:color [^>]*/>}{}g;
$xml =~ s{<w:sz w:val="\d+"\s*/>}{<w:sz w:val="24"/>}g;
$xml =~ s{<w:szCs w:val="\d+"\s*/>}{<w:szCs w:val="24"/>}g;
$xml =~ s{<w:pPrDefault>.*?</w:pPrDefault>}{<w:pPrDefault><w:pPr>$single</w:pPr></w:pPrDefault>}s or die 'reference: no pPrDefault';
open my $out, '>:encoding(UTF-8)', $styles or die; print $out $xml; close $out;

# Page setup: letter, 1 in margins, the footer part carries the page number.
my $d = do { local $/; open my $fh, '<:encoding(UTF-8)', $doc or die; <$fh> };
$d =~ s{<w:sectPr[^>]*>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooterCourt"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s or die 'reference: no sectPr';
open $out, '>:encoding(UTF-8)', $doc or die; print $out $d; close $out;

my $r = do { local $/; open my $fh, '<:encoding(UTF-8)', $rels or die; <$fh> };
$r =~ s{</Relationships>}{<Relationship Id="rIdFooterCourt" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>} or die 'reference: no Relationships';
open $out, '>:encoding(UTF-8)', $rels or die; print $out $r; close $out;

my $c = do { local $/; open my $fh, '<:encoding(UTF-8)', $ct or die; <$fh> };
$c =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>} or die 'reference: no Types';
open $out, '>:encoding(UTF-8)', $ct or die; print $out $c; close $out;
PERL
perl "$W/patch.pl" word/styles.xml word/document.xml word/_rels/document.xml.rels '[Content_Types].xml'
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:r><w:t xml:space="preserve">- </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:r><w:t xml:space="preserve"> -</w:t></w:r></w:p></w:ftr>
XML
rm -f "$D/reference.docx"
zip -q -X -r "$D/reference.docx" '[Content_Types].xml' _rels docProps word
echo "$D/reference.docx"
