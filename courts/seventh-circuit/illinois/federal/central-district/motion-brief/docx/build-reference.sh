#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx, to match motion-brief/typst/ilcd-motion-brief.typ:
# EB Garamond 12 pt; body paragraphs at exact 24 pt (double spacing, LR 5.1(B)(1)) with a 0.5 in first-line indent;
# headings with one double line above (typst "body-leading" above and below); block quotations single-spaced and
# indented 0.5 in each side; footnotes 10 pt single (LR 5.1(B)(2)); letter paper, 1 in margins (LR 5.1(A)).
# Single-spaced paragraph styles (exact 13.8 pt, the typst single leading): "Centered", "Single", "Signature"
# (keep with next), "Counsel" (at 3.25 in, the counsel and signature block), "Dated" (tab at 3.25 in),
# "Authority" and "AuthorityHead" (the table of authorities), "BodyKeep" (body text kept with the signature).
# Footer: a centered PAGE field. The sections (cover, front matter in roman, body in arabic) are set in the filter.
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
my $HEAD   = '<w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/>';
my $SINGLE = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>';
my $SZ12   = '<w:sz w:val="24"/><w:szCs w:val="24"/>';

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

sub addstyle {
  my ($id, $ppr, $rpr) = @_;
  die "styles.pl: $id exists\n" if $s =~ /w:styleId="\Q$id\E"/;
  my $xml = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$id"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$ppr</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
  $s =~ s{</w:styles>}{$xml</w:styles>} or die "styles.pl: no </w:styles>\n";
}

$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$FONT$SZ12<w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s
  or die "styles.pl: no docDefaults\n";

restyle('Normal', qq{<w:widowControl/>$DOUBLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
restyle('BodyText', qq{$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");
restyle('FirstParagraph', qq{$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");
restyle('Heading1', qq{<w:keepNext/><w:keepLines/>$HEAD<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>},
  qq{$FONT<w:b/><w:bCs/><w:caps/><w:color w:val="000000"/>$SZ12});
restyle('Heading2', qq{<w:keepNext/><w:keepLines/>$HEAD<w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/>},
  qq{$FONT<w:b/><w:bCs/><w:color w:val="000000"/>$SZ12});
restyle('Heading3', qq{<w:keepNext/><w:keepLines/>$HEAD<w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/>},
  qq{$FONT<w:b/><w:bCs/><w:color w:val="000000"/>$SZ12});
restyle('Heading4', qq{<w:keepNext/><w:keepLines/>$HEAD<w:ind w:left="1440" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/>},
  qq{$FONT<w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/>$SZ12});
restyle('BlockText', qq{<w:spacing w:before="480" w:after="480" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/>},
  "$FONT$SZ12");
restyle('FootnoteText', qq{<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>},
  qq{$FONT<w:sz w:val="20"/><w:szCs w:val="20"/>});

addstyle('Centered', qq{$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="center"/>}, "$FONT$SZ12");
addstyle('Single', qq{$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Signature', qq{<w:keepNext/><w:keepLines/>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Counsel', qq{<w:keepNext/><w:keepLines/>$SINGLE<w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Dated', qq{<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="4680"/></w:tabs>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('Authority', qq{<w:keepLines/><w:spacing w:before="0" w:after="138" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");
addstyle('AuthorityHead', qq{<w:keepNext/><w:spacing w:before="480" w:after="138" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>}, qq{$FONT<w:b/><w:bCs/>$SZ12});
addstyle('BodyKeep', qq{<w:keepNext/><w:keepLines/>$DOUBLE<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "$FONT$SZ12");

open my $out, '>', $f or die "$f: $!\n";
print $out $s;
close $out;
PERL
perl "$W/styles.pl" word/styles.xml

cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# body section (the last section of the document): letter, 1 in margins, the page-number footer, arabic from 1
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
