#!/bin/sh
# Build docx/reference.docx for the CIT motion-brief from pandoc's default reference: EB Garamond 12 pt
# (Normal and footnotes), double spacing (24 pt exact) for body text and list items, single spacing
# (auto) for headings, block quotations, footnotes and counsel lines, letter paper, 1 in margins, a
# centered page number at the foot of every page. Same form as typst/cit-motion-brief.typ.
# Usage: sh make-reference.sh <out.docx>   (needs pandoc, zip, unzip, perl)
set -eu
OUT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W"
unzip -q ref.docx -d x

cat > patch.pl <<'PERL'
# Edits word/styles.xml (file in $ARGV[0]) in place. pPr and rPr are appended after the other style
# children, which is the order the schema requires.
use strict;
my $f = shift;
open(my $in, '<:encoding(UTF-8)', $f) or die "$f: $!";
local $/;
my $s = <$in>;
close $in;

sub setsty {
  my ($id, $ppr, $rpr) = @_;
  my $ok = $s =~ s{(<w:style [^>]*w:styleId="\Q$id\E"[^>]*>)(.*?)(</w:style>)}{
    my ($o, $b, $c) = ($1, $2, $3);
    $b =~ s{<w:pPr>.*?</w:pPr>}{}s;
    $b =~ s{<w:rPr>.*?</w:rPr>}{}s;
    $b .= "<w:pPr>$ppr</w:pPr>" if $ppr ne "";
    $b .= "<w:rPr>$rpr</w:rPr>" if $rpr ne "";
    $o . $b . $c;
  }se;
  die "style $id not found\n" unless $ok;
}

sub addsty {
  my ($id, $name, $ppr, $rpr) = @_;
  my $x = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/><w:basedOn w:val="Normal"/><w:qFormat/>}
        . ($ppr ne "" ? "<w:pPr>$ppr</w:pPr>" : "") . ($rpr ne "" ? "<w:rPr>$rpr</w:rPr>" : "") . "</w:style>";
  $s =~ s{</w:styles>}{$x</w:styles>};
}

my $font = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>};
my $dbl  = q{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>};
my $sgl  = q{<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>};
my $tab  = q{<w:tabs><w:tab w:val="left" w:pos="1584"/></w:tabs>};

# document defaults: EB Garamond 12 pt everywhere, unless a style says otherwise
$s =~ s{<w:rPrDefault>.*?</w:rPrDefault>}{<w:rPrDefault><w:rPr>$font<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault>}s;

setsty("Normal", $sgl, qq{$font<w:sz w:val="24"/><w:szCs w:val="24"/>});
# numbered allegations: first line indented 0.5 in, the number, then a tab to 1.1 in (Rule 10(b))
setsty("BodyText", qq{$tab$dbl<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "");
setsty("FirstParagraph", qq{$tab$dbl<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "");
setsty("Compact", qq{$dbl<w:jc w:val="left"/>}, "");
setsty("BlockText", q{<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/>}, "");
setsty("FootnoteText", q{<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>}, q{<w:sz w:val="24"/><w:szCs w:val="24"/>});
setsty("Heading1", q{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>},
  qq{$font<w:b/><w:caps/><w:sz w:val="24"/><w:szCs w:val="24"/>});
setsty("Heading2", q{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/>},
  qq{$font<w:b/><w:sz w:val="24"/><w:szCs w:val="24"/>});
for my $n (3 .. 5) {
  setsty("Heading$n", q{<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/>},
    qq{$font<w:b/><w:i/><w:sz w:val="24"/><w:szCs w:val="24"/>});
}
# lettered list items (a), (b), ...: marker at 0.5 in, text at 0.9 in
addsty("CITItem", "CIT Item", qq{$tab$dbl<w:ind w:left="1296" w:hanging="576"/><w:jc w:val="left"/>}, "");
# the WHEREFORE paragraph: kept on the same page as the signature block that follows it
addsty("CITKeep", "CIT Keep", qq{<w:keepNext/><w:keepLines/>$tab$dbl<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "");
# counsel and signature lines: single spaced, left
addsty("CITSingle", "CIT Single", qq{$sgl<w:jc w:val="left"/>}, "");

open(my $out, '>:encoding(UTF-8)', $f) or die "$f: $!";
print $out $s;
close $out;
PERL
perl patch.pl x/word/styles.xml

# page: letter, 1 in margins (typed matter 6 1/2 x 9 in; Rule 81(f))
perl -0777 -i -pe '
  s{<w:pgSz[^>]*/>}{<w:pgSz w:w="12240" w:h="15840"/>}g;
  s{<w:pgMar[^>]*/>}{<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>}g;
  s{(<w:sectPr[^>]*>)}{$1<w:footerReference w:type="default" r:id="rIdCITFooter"/>}g;
' x/word/document.xml

# footer: centered page number (Rule 81(d), (f): numbered consecutively from 1, on the bottom)
cat > x/word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' x/\[Content_Types\].xml
perl -0777 -i -pe 's{</Relationships>}{<Relationship Id="rIdCITFooter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>}' x/word/_rels/document.xml.rels

(cd x && zip -q -X -r "$W/out.docx" .)
cp "$W/out.docx" "$OUT"
echo "$OUT"
