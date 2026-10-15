#!/bin/sh
# Builds docx/reference.docx for the E.D. Mich. bankruptcy adversary complaint (mieb), from pandoc's default reference.
# Form (typst/mieb-adversary-complaint.typ, the reference for the mandated form): EB Garamond 14 pt (vendored, see
# ../README.md), exact 28 pt line pitch (double spacing, the pitch the typst template measures), no first-line indent,
# letter paper, 1 in margins, "N of M" centered in the footer at 14 pt.
# Headings (Heading 1 and 2) are centered and bold, kept with the next paragraph. Footnote text is 14 pt single spaced.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, xmllint, perl on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# Style definitions: replaces pandoc's styles of the same ID and appends the custom ones.
cat > "$W/new-styles.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="560" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleRight"><w:name w:val="Single Right"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature Block"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
XML
# The merge: each style in new-styles.xml replaces the pandoc style with the same styleId, the rest are appended.
cat > "$W/merge-styles.pl" <<'PL'
# Merge $W/new-styles.xml into word/styles.xml. Argument 1: the new-styles file; argument 2: the styles file.
use strict; use warnings;
my ($new, $target) = @ARGV;
local $/;
open(my $nh, '<', $new) or die "open $new: $!";
my $n = <$nh>; close $nh;
open(my $th, '<', $target) or die "open $target: $!";
my $t = <$th>; close $th;
my $dd = '';
if ($n =~ s{(<w:docDefaults>.*?</w:docDefaults>)}{}s) { $dd = $1 }
$t =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults in $target\n";
my @styles = $n =~ m{(<w:style .*?</w:style>)}sg;
my $append = '';
for my $s (@styles) {
  my ($id) = $s =~ m{w:styleId="([^"]+)"};
  die "style without id\n" unless defined $id;
  if ($t =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$s}s) { next }
  $append .= $s;
}
$t =~ s{</w:styles>}{$append</w:styles>}s;
open(my $oh, '>', $target) or die "write $target: $!";
print $oh $t; close $oh;
PL
perl "$W/merge-styles.pl" "$W/new-styles.xml" word/styles.xml
# pandoc's verbatim style (unused here) names Consolas, a system font outside fonts/: point it at the vendored family.
sed -i 's/Consolas/EB Garamond/g' word/styles.xml
# Footer: "N of M" centered at 14 pt (typst footer), PAGE and NUMPAGES fields with cached results.
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:r><w:t xml:space="preserve"> of </w:t></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> NUMPAGES </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
grep -q 'rId100' word/_rels/document.xml.rels || sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
grep -q 'footer1.xml' '[Content_Types].xml' || sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# Body section: letter, 1 in margins, the footer. Replaces the last sectPr of the body.
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>(\s*</w:body>)}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>$1}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
