#!/bin/sh
# Builds docx/reference.docx for the nysupct memorandum of law from pandoc's default reference (pandoc 3.12).
# Mandated form (22 NYCRR 202.5(a)(1); CPLR 2101(a)): print no smaller than 12 pt; double spacing;
# margins no smaller than 1 in; letter paper. Footnotes 11 pt (the 10 pt floor is met; 11 pt as typst/).
# Body: EB Garamond 12 pt (the no-face default, docs/FONTS.md), double line spacing (w:line 480 auto),
# first-line indent 0.5 in. Page number: centred PAGE field in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
BODY_PT=12
FOOTNOTE_PT=11
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/ref.docx"

cat > "$W/patch.pl" <<'PERL'
use strict;
my ($styles, $doc, $body_pt, $fn_pt) = @ARGV;
my $sz  = $body_pt * 2;
my $fsz = $fn_pt * 2;
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
sub slurp { my $f = shift; local $/; open my $h, '<', $f or die "$f: $!"; my $s = <$h>; close $h; $s }
sub spit  { my ($f, $s) = @_; open my $h, '>', $f or die "$f: $!"; print $h $s; close $h }

my $s = slurp($styles);
# every font reference becomes the court font (pandoc's defaults use theme fonts)
$s =~ s{<w:rFonts [^>]*/>}{$font}g;
# black text everywhere (pandoc's headings are blue)
$s =~ s{ w:themeColor="[^"]*"}{}g;
$s =~ s{ w:themeShade="[^"]*"}{}g;
$s =~ s{ w:themeTint="[^"]*"}{}g;
$s =~ s{<w:color w:val="[0-9A-Fa-f]{6}"}{<w:color w:val="000000"}g;

sub put {
  my ($id, $xml) = @_;
  $s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$xml}s
    or $s =~ s{</w:styles>}{$xml</w:styles>};
}
my $dbl = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/>';
my $sgl = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>';
my $rsz = "<w:rPr>$font<w:sz w:val=\"$sz\"/><w:szCs w:val=\"$sz\"/></w:rPr>";

put('Normal', qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>$dbl<w:ind w:firstLine="0"/></w:pPr>$rsz</w:style>});
put('BodyText', qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$dbl<w:ind w:firstLine="720"/></w:pPr></w:style>});
put('FirstParagraph', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>$dbl<w:ind w:firstLine="720"/></w:pPr></w:style>});
put('Compact', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$dbl<w:ind w:firstLine="0"/></w:pPr></w:style>});
put('BlockText', qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>$sgl<w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>});
# headings: level 1 centred bold; level 2 bold; level 3 bold italic (typst/nysupct-complaint.typ)
put('Heading1', qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$sgl<w:spacing w:before="280" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="$sz"/><w:szCs w:val="$sz"/></w:rPr></w:style>});
put('Heading2', qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="$sz"/><w:szCs w:val="$sz"/></w:rPr></w:style>});
put('Heading3', qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:sz w:val="$sz"/><w:szCs w:val="$sz"/></w:rPr></w:style>});
# footnotes: single spaced, 10 pt
put('FootnoteText', qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$fsz"/><w:szCs w:val="$fsz"/></w:rPr></w:style>});
# custom paragraph styles used by the caption, signature, service list and verification
put('Centered', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$sgl<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>});
put('Single', qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$sgl<w:ind w:firstLine="0"/></w:pPr></w:style>});
# table of contents entries (the TOC field's cached result uses these)
for my $n (1 .. 4) {
  my $left = 360 * ($n - 1);
  put("TOC$n", qq{<w:style w:type="paragraph" w:styleId="TOC$n"><w:name w:val="toc $n"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr>$sgl<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="$left" w:firstLine="0"/></w:pPr></w:style>});
}
spit($styles, $s);

# body section: letter, 1 in margins, footer with the page number (rIdFtr1)
my $d = slurp($doc);
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:start="1"/></w:sectPr>';
$d =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s or $d =~ s{</w:body>}{$sect</w:body>};
spit($doc, $d);
PERL
perl "$W/patch.pl" word/styles.xml word/document.xml "$BODY_PT" "$FOOTNOTE_PT"

cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$part"
done
rm -f "$OUT"
zip -q -X -nw "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" . -x '[Content_Types].xml'
echo "$OUT"
