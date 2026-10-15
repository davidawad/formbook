#!/bin/sh
# Builds docx/reference.docx for nmb (Bankr. D.N.M.) from pandoc's default reference.docx.
# Mirrors typst/nmb-*.typ: EB Garamond 12 pt (no typeface rule; the vendored serif), exact 24 pt
# (double) line spacing, exact 15 pt single lines for block quotations and the signature block's
# counsel lines, first-line indent 0.5 in for numbered paragraphs, 1 in margins on letter paper,
# footnotes and footer 10 pt, footer "Page X of Y" (PAGE and NUMPAGES fields).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/ref.docx"
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/ref.docx"

# styles.xml: replace the doc defaults and the styles this template uses (pandoc's default
# reference.docx is multi-line XML, so the patch is whole-element and whitespace-tolerant).
perl -0777 - word/styles.xml <<'PL'
my $f = shift;
open my $h, '<:encoding(UTF-8)', $f or die "open $f: $!";
my $s = do { local $/; <$h> };
close $h;
my $F = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
sub setstyle {
  my ($id, $xml) = @_;
  return if $s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$xml}s;
  $s =~ s{</w:styles>}{$xml</w:styles>} or die "no </w:styles> in $f";
}
my $dd = qq{<w:docDefaults><w:rPrDefault><w:rPr>$F<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>};
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults";
my $double = q{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>};
setstyle('Normal', qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:firstLine="0"/></w:pPr><w:rPr>$F<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>});
setstyle('BodyText', qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:firstLine="0"/></w:pPr></w:style>});
setstyle('FirstParagraph', qq{<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$double<w:ind w:firstLine="0"/></w:pPr></w:style>});
setstyle('Compact', qq{<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$double</w:pPr></w:style>});
for my $n (1 .. 3) {
  setstyle("Heading$n", qq{<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$double<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="@{[$n-1]}"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>});
}
setstyle('BlockText', qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="144" w:line="300" w:lineRule="exact"/><w:ind w:left="1080" w:right="1080" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>});
setstyle('FootnoteText', qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>});
setstyle('Footer', qq{<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>});
# custom paragraph styles used by the Lua filter and the raw caption/signature XML
setstyle('Indented', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Indented"><w:name w:val="Indented"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:firstLine="720"/></w:pPr></w:style>});
setstyle('SubItem', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SubItem"><w:name w:val="SubItem"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>});
setstyle('Centered', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>});
setstyle('Single', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>});
setstyle('Cell', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Cell"><w:name w:val="Cell"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:firstLine="0"/></w:pPr></w:style>});
setstyle('Signature', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$double<w:ind w:left="4680" w:firstLine="0"/></w:pPr></w:style>});
open my $o, '>:encoding(UTF-8)', $f or die "write $f: $!";
print $o $s;
close $o;
PL

# document.xml: one section, letter, 1 in margins, footer with the page-number fields
perl -0777 -i -pe 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s or die "no sectPr"' word/document.xml

# footer part: "Page X of Y" right-aligned, 10 pt (the footer title is case text, so it is not in the template)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:t xml:space="preserve">Page </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:r><w:t xml:space="preserve"> of </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> NUMPAGES </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
unzip -tq "$OUT" > /dev/null
echo "$OUT"
