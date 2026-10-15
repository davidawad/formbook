#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx, to match complaint/typst/ilcd-complaint.typ:
# EB Garamond 12 pt; body paragraphs at exact 24 pt (double spacing, LR 5.1(B)(1)) with a 0.5 in first-line indent;
# letter paper, 1 in margins (LR 5.1(A)); a centered PAGE number in the footer on every page.
# Custom paragraph styles for the cover, caption, signature block and numbered paragraphs: "Centered" and "Single"
# (exact 13.8 pt, the typst single leading), "Signature" (single, keep with next), "Numbered", "Lettered".
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/ref.docx"

cat > "$W/styles.pl" <<'PERL'
my $f = shift @ARGV or die "usage: styles.pl word/styles.xml\n";
open my $in, '<', $f or die "$f: $!\n";
my $s = do { local $/; <$in> };
close $in;

my $FONT   = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $DOUBLE = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>';
my $SZ12   = '<w:sz w:val="24"/><w:szCs w:val="24"/>';

# replace the paragraph and character properties of a built-in style, keeping its name and links
sub restyle {
  my ($id, $ppr, $rpr) = @_;
  my $re = qr{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}s;
  my ($block) = $s =~ /($re)/ or die "styles.pl: no style $id\n";
  my $new = $block;
  $new =~ s{<w:pPr>.*?</w:pPr>}{}s;
  $new =~ s{<w:rPr>.*?</w:rPr>}{}s;
  $new =~ s{</w:style>$}{$ppr$rpr</w:style>}s;
  $s =~ s/\Q$block\E/$new/;
}

# add a custom paragraph style
sub addstyle {
  my ($id, $ppr, $rpr) = @_;
  die "styles.pl: $id exists\n" if $s =~ /w:styleId="\Q$id\E"/;
  my $xml = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$id"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
  $s =~ s{</w:styles>}{$xml</w:styles>} or die "styles.pl: no </w:styles>\n";
}

# document defaults: EB Garamond 12 pt
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$FONT$SZ12<w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s
  or die "styles.pl: no docDefaults\n";

restyle('Normal', qq{<w:widowControl/>$DOUBLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
restyle('BodyText', qq{$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");
restyle('FirstParagraph', qq{$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");
# headings: centered, bold, one double-spaced line, kept with the paragraph after them (LR 5.1(B)(1))
restyle('Heading1', qq{<w:keepNext/><w:keepLines/>$DOUBLE<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>},
  qq{$FONT<w:b/><w:bCs/><w:caps/><w:color w:val="000000"/>$SZ12});
restyle('Heading2', qq{<w:keepNext/><w:keepLines/>$DOUBLE<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/>},
  qq{$FONT<w:b/><w:bCs/><w:color w:val="000000"/>$SZ12});
restyle('Heading3', qq{<w:keepNext/><w:keepLines/>$DOUBLE<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="2"/>},
  qq{$FONT<w:b/><w:bCs/><w:color w:val="000000"/>$SZ12});
# footnotes: 10 pt, single (LR 5.1(B)(2) allows footnotes no smaller than 10 pt; not used by the complaint)
restyle('FootnoteText', qq{<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>},
  qq{$FONT<w:sz w:val="20"/><w:szCs w:val="20"/>});

addstyle('Centered', qq{$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="center"/>}, "$FONT$SZ12");
addstyle('Single', qq{$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Signature', qq{<w:keepNext/><w:keepLines/>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Numbered', qq{<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Lettered', qq{<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>$DOUBLE<w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");

open my $out, '>', $f or die "$f: $!\n";
print $out $s;
close $out;
PERL
perl "$W/styles.pl" word/styles.xml

# footer with the page number: a centered PAGE field (cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# body section: letter, 1 in margins, the page-number footer (replaces the default section properties)
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
