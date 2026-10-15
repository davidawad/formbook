#!/bin/sh
# Builds docx/reference.docx for the E.D. Ky. memorandum in support of a motion from pandoc's default reference (docs/DOCX.md).
# Form (KYED-FORM-001, -002; the same page and type settings as the complaint): US Letter, 1 in margins on all sides; EB Garamond 12 pt (the vendored family,
# fonts/eb-garamond); body text exactly 24 pt (double) line pitch with a 0.5 in first-line indent; headings,
# block quotations, signature block and footnotes single spaced; centered page number in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl and xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# New and replaced styles (one w:style element each; replaced by styleId). Order inside pPr/rPr follows the schema.
cat > "$W/styles.frag" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1080" w:right="1080" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="2160" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="CourtTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionTitle"><w:name w:val="CaptionTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="480" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PartyV"><w:name w:val="PartyV"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1728" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PartyDesig"><w:name w:val="PartyDesig"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:right="432" w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRule"><w:name w:val="CaptionRule"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="4"/><w:szCs w:val="4"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="4896" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigTop"><w:name w:val="SigTop"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigKeep"><w:name w:val="SigKeep"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigGap"><w:name w:val="SigGap"/><w:basedOn w:val="SigKeep"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLast"><w:name w:val="SigLast"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigDated"><w:name w:val="SigDated"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="4896"/></w:tabs><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="BodyKeep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertHeading"><w:name w:val="CertHeading"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:pageBreakBefore/><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertText"><w:name w:val="CertText"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ServiceKeep"><w:name w:val="ServiceKeep"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ServiceLast"><w:name w:val="ServiceLast"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="180" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
XML

# Replace each style above by styleId (or add it), replace docDefaults, and set the body section (letter, 1 in
# margins, footer with the page number). The footer part is a PAGE field with cached result 1.
cat > "$W/fix.pl" <<'PERL'
use strict; use warnings;
my ($dir, $frag) = @ARGV;
sub slurp { my $f = shift; open my $h, '<:encoding(UTF-8)', $f or die "$f: $!"; local $/; my $s = <$h>; close $h; $s }
sub spew { my ($f, $s) = @_; open my $h, '>:encoding(UTF-8)', $f or die "$f: $!"; print $h $s; close $h }
my $st = slurp("$dir/word/styles.xml");
my $new = slurp($frag);
my $dd = <<'DD';
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
DD
$st =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults";
for my $s ($new =~ m{(<w:style .*?</w:style>)}gs) {
  my ($id) = $s =~ m{w:styleId="([^"]+)"};
  $st =~ s{<w:style [^>]*?w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s;
  $st =~ s{</w:styles>}{$s\n</w:styles>}s;
}
spew("$dir/word/styles.xml", $st);
my $footer = <<'FTR';
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
FTR
spew("$dir/word/footer1.xml", $footer);
my $rels = slurp("$dir/word/_rels/document.xml.rels");
$rels =~ s{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>} or die "rels";
spew("$dir/word/_rels/document.xml.rels", $rels);
my $ct = slurp("$dir/[Content_Types].xml");
$ct =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>} or die "ct";
spew("$dir/[Content_Types].xml", $ct);
my $doc = slurp("$dir/word/document.xml");
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
$doc =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s or die "no sectPr";
spew("$dir/word/document.xml", $doc);
PERL
perl "$W/fix.pl" "$W/pkg" "$W/styles.frag"
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
cd "$W/pkg" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
