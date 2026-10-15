#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for N.D. Ga. (gand) motion briefs: Times New Roman
# 14 pt (LR 5.1(C)), double-spaced body at the typst pitch (644 twips = 32.2 pt, exact), single-spaced headings,
# block quotations and footnotes, 1 in margins on US Letter (LR 5.1(D)), and a centered PAGE field in the
# footer (LR 5.1(E)). Same geometry as typst/gand-motion-brief.typ. Run once (needs pandoc, unzip, zip, perl);
# the result is committed. Usage: sh docx/make-reference.sh   (from the doc-type folder)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
H2_JC=left # motion brief: level-2 headings are bold, left (the letters are typed by the author)
export H2_JC
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"

cat > "$W/styles.pl" <<'PERL'
# Edits pandoc's styles.xml: fonts, sizes, spacing and the GAND paragraph styles. Reads and writes the whole file.
use strict;
use warnings;
local $/;
my $s = <>;
my $tnr = '<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/>';
my $sz = '<w:sz w:val="28"/><w:szCs w:val="28"/>';
my $sgl = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>';
my $dbl = '<w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact"/>';
my $h2jc = $ENV{H2_JC} // 'center';

# No theme fonts or colours: every run is Times New Roman, black.
$s =~ s{<w:rFonts [^>]*/>}{$tnr}g;
$s =~ s{<w:color [^>]*/>}{<w:color w:val="000000"/>}g;
$s =~ s{<w:spacing w:after="[0-9]+" w:line="[0-9]+" w:lineRule="auto"\s*/>}{$sgl}g;

# Set the pPr and rPr of a style by styleId. They are appended after the style's other children (the schema
# order: name, basedOn, ..., pPr, rPr).
sub setsty {
  my ($id, $ppr, $rpr) = @_;
  $s =~ s{(<w:style [^>]*w:styleId="\Q$id\E"[^>]*>)(.*?)(</w:style>)}{
    my ($open, $body, $close) = ($1, $2, $3);
    $body =~ s{<w:pPr>.*?</w:pPr>}{}s;
    $body =~ s{<w:rPr>.*?</w:rPr>}{}s;
    $body .= "<w:pPr>$ppr</w:pPr>" if $ppr ne '';
    $body .= "<w:rPr>$rpr</w:rPr>" if $rpr ne '';
    $open . $body . $close;
  }seg;
}

# A custom paragraph style the filter applies with a custom-style Div.
sub addsty {
  my ($id, $name, $based, $ppr, $rpr) = @_;
  my $x = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/><w:basedOn w:val="$based"/><w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
  $s =~ s{</w:styles>}{$x</w:styles>};
}

setsty('Normal', $sgl, "$tnr$sz");
setsty('BodyText', qq{$dbl<w:ind w:firstLine="720"/>}, "$tnr$sz");
setsty('FirstParagraph', qq{$dbl<w:ind w:firstLine="720"/>}, "$tnr$sz");
setsty('Compact', $dbl, "$tnr$sz");
setsty('BlockText', qq{<w:spacing w:before="0" w:after="644" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720"/>}, "$tnr$sz");
setsty('FootnoteText', q{<w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/>}, "$tnr$sz");
setsty('Heading1', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>}, qq{$tnr<w:b/><w:bCs/><w:caps/>$sz});
setsty('Heading2', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:jc w:val="$h2jc"/>}, qq{$tnr<w:b/><w:bCs/>$sz});
setsty('Heading3', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/>}, qq{$tnr<w:b/><w:bCs/>$sz});

# Numbered allegations: "1." then a tab to 1 in (typed numbers, as the typst template).
addsty('GANDNumbered', 'GAND Numbered', 'BodyText', qq{<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>$dbl<w:ind w:firstLine="720"/>}, "$tnr$sz");
# Lettered prayer items: "A." at 0.5 in, text at 1 in (hanging).
addsty('GANDLettered', 'GAND Lettered', 'BodyText', qq{<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>$dbl<w:ind w:left="1440" w:hanging="720"/>}, "$tnr$sz");
# Cover lines: court title (single, bold, centred); the last line of the title block carries the gap below.
addsty('GANDCourtTitle', 'GAND Court Title', 'Normal', qq{<w:keepNext/><w:keepLines/>$sgl<w:jc w:val="center"/>}, qq{$tnr<w:b/><w:bCs/>$sz});
addsty('GANDCourtTitleLast', 'GAND Court Title Last', 'GANDCourtTitle', q{<w:spacing w:before="0" w:after="644" w:line="240" w:lineRule="auto"/>}, '');
addsty('GANDCoverTitle', 'GAND Cover Title', 'Normal', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>}, qq{$tnr<w:b/><w:bCs/><w:caps/>$sz});
# Caption rows: one exact line height (19.6 pt, the typst caption line), so the parenthesis column lines up.
addsty('GANDCaption', 'GAND Caption', 'Normal', q{<w:spacing w:before="0" w:after="0" w:line="392" w:lineRule="exact"/>}, "$tnr$sz");
# Signature block: a blank double line above it (the typst v(body-leading)), then lines indented 2.7 in
# (3888 twips), single-spaced and kept together. The left lines ("Dated:", "Respectfully submitted,") use the
# Lead style; a 4 pt gap separates the groups of the block.
addsty('GANDSignatureLead', 'GAND Signature Lead', 'Normal', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="0" w:line="240" w:lineRule="auto"/>}, "$tnr$sz");
addsty('GANDSignatureBlockLead', 'GAND Signature Block Lead', 'Normal', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="3888"/>}, "$tnr$sz");
addsty('GANDSignatureBlock', 'GAND Signature Block', 'Normal', qq{<w:keepNext/><w:keepLines/>$sgl<w:ind w:left="3888"/>}, "$tnr$sz");
addsty('GANDSignatureGap', 'GAND Signature Gap', 'Normal', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="80" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="3888"/>}, "$tnr$sz");
addsty('GANDSignatureRight', 'GAND Signature Right', 'Normal', qq{<w:keepLines/>$sgl<w:jc w:val="right"/>}, "$tnr$sz");
# Certificates (LR 7.1(D)): a centred bold heading, then double-spaced paragraphs, a blank double line after each.
addsty('GANDCertificateHeading', 'GAND Certificate Heading', 'Normal', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>}, qq{$tnr<w:b/><w:bCs/>$sz});
addsty('GANDCertificateBody', 'GAND Certificate Body', 'BodyText', qq{<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="644" w:line="644" w:lineRule="exact"/><w:ind w:firstLine="720"/>}, "$tnr$sz");
print $s;
PERL
perl "$W/styles.pl" "$W/x/word/styles.xml" > "$W/styles.new"
mv "$W/styles.new" "$W/x/word/styles.xml"

# Page: US Letter, 1 in margins; footer with a centred PAGE field (LR 5.1(E)).
cat > "$W/x/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{<Relationships ([^>]*)>}{<Relationships $1><Relationship Id="rIdGandFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/>}' "$W/x/word/_rels/document.xml.rels"
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$W/x/[Content_Types].xml"
perl -0777 -i -pe '
  s{(<w:sectPr[^>]*>)}{$1<w:footerReference w:type="default" r:id="rIdGandFooter1"/>}g;
  s{(</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>}g;
' "$W/x/word/document.xml"
# pandoc's default reference has no page size: the sectPr must carry one (the insert above needs its footnotePr).
grep -q '<w:pgSz w:w="12240" w:h="15840"/>' "$W/x/word/document.xml" || {
  echo "make-reference.sh: the section has no page size to set" >&2
  exit 1
}

for part in "$W/x/word/styles.xml" "$W/x/word/document.xml" "$W/x/word/footer1.xml" "$W/x/word/_rels/document.xml.rels" "$W/x/[Content_Types].xml"; do
  xmllint --noout "$part"
done
rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
