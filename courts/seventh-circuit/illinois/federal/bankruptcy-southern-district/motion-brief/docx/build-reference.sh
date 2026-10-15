#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx, to the S.D. Ill. form of the typst template:
# EB Garamond 12 pt, exact 24 pt (double) line spacing for body text, first-line indent 0.5 in, letter page with
# 1 in margins, a "Page x of y" footer at 10 pt. Front matter styles (Centered, Single, Gap, Prayer, ...) are
# added for the cover, caption, signature and certificate paragraphs. Same script in every doc type folder.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# styles.xml: the body style set, the heading styles, footnotes and the custom front-matter styles.
cat > "$W/styles.pl" <<'PERL'
use strict;
use warnings;
local $/;
my $f = shift;
open my $fh, '<:encoding(UTF-8)', $f or die "$f: $!";
my $s = <$fh>;
close $fh;

my $FONT = 'w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"';
$s =~ s{<w:rFonts [^>]*/>}{<w:rFonts $FONT/>}g;

# document defaults: 12 pt, exact 24 pt line pitch, no space after
$s =~ s{(<w:pPrDefault>).*?(</w:pPrDefault>)}{$1<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr>$2}s
  or die "no pPrDefault";

my $BODY_SP = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SINGLE_SP = '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/>';
my %ppr = (
  Normal         => qq{$BODY_SP<w:ind w:firstLine="0"/>},
  BodyText       => qq{$BODY_SP<w:ind w:firstLine="720"/>},
  FirstParagraph => qq{$BODY_SP<w:ind w:firstLine="720"/>},
  Compact        => qq{$BODY_SP<w:ind w:firstLine="0"/>},
  BlockText      => qq{<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/>},
  FootnoteText   => q{<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>},
  Heading1       => q{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>},
  Heading2       => q{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>},
  Heading3       => q{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/>},
);
my $BOLD = qq{<w:rFonts $FONT/><w:b/><w:bCs/>};
my $SZ = q{<w:sz w:val="24"/><w:szCs w:val="24"/>};
my %rpr = (
  Heading1 => qq{$BOLD<w:caps/><w:color w:val="000000"/>$SZ},
  Heading2 => qq{$BOLD<w:color w:val="000000"/>$SZ},
  Heading3 => qq{$BOLD<w:color w:val="000000"/>$SZ},
  FootnoteText => qq{<w:rFonts $FONT/><w:sz w:val="24"/><w:szCs w:val="24"/>},
);
for my $id (sort keys %ppr) {
  my $re = qr{(<w:style [^>]*w:styleId="\Q$id\E"[^>]*>)(.*?)(</w:style>)}s;
  $s =~ $re or die "no style $id";
  my ($open, $body, $close) = ($1, $2, $3);
  my $pp = "<w:pPr>$ppr{$id}</w:pPr>";
  if ($body =~ s{<w:pPr>.*?</w:pPr>}{$pp}s) { }
  else { $body =~ s{(?=<w:rPr>|<w:tblPr>|$)}{$pp}s }
  if (exists $rpr{$id}) {
    my $rp = "<w:rPr>$rpr{$id}</w:rPr>";
    if ($body =~ s{<w:rPr>.*?</w:rPr>}{$rp}s) { }
    else { $body .= $rp }
  }
  my $new = "$open$body$close";
  $s =~ s{\Q$open\E.*?\Q$close\E}{$new}s;
}

# custom paragraph styles (front matter, signature, caption and prayer lines); footer style
my $custom = join '',
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE_SP<w:ind w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Half"><w:name w:val="Half"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="PageBreak"><w:name w:val="PageBreak"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Prayer"><w:name w:val="Prayer"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1152"/></w:tabs>$BODY_SP<w:ind w:left="1152" w:hanging="432"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Exhibit"><w:name w:val="Exhibit"/><w:basedOn w:val="Normal"/><w:pPr><w:tabs><w:tab w:val="left" w:pos="2016"/></w:tabs><w:spacing w:before="0" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:left="2016" w:hanging="2016"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>};
$s =~ s{</w:styles>}{$custom</w:styles>} or die "no </w:styles>";
open my $out, '>:encoding(UTF-8)', $f or die;
print $out $s;
close $out;
PERL
perl "$W/styles.pl" word/styles.xml

# body section: letter, 1 in margins, the page-number footer (replaces pandoc's section properties)
cat > "$W/sect.pl" <<'PERL'
use strict;
use warnings;
local $/;
my $f = shift;
open my $fh, '<:encoding(UTF-8)', $f or die;
my $s = <$fh>;
close $fh;
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
my $n = ($s =~ s{<w:sectPr\b.*?</w:sectPr>}{$sect}sg);
open my $out, '>:encoding(UTF-8)', $f or die;
print $out $s;
close $out;
die "no body sectPr in document.xml\n" if $n == 0;
PERL
perl "$W/sect.pl" word/document.xml

# footer: "Page x of y" (PAGE and NUMPAGES fields; the cached results are placeholders that the viewer updates)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:t xml:space="preserve">Page </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:r><w:t xml:space="preserve"> of </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> NUMPAGES </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
