#!/bin/sh
# Builds docx/reference.docx for the USCMCR brief (typst/ is the form): Liberation Serif 12 pt (the
# Times New Roman substitute, docs/FONTS.md), body text at 25.2 pt exact (the typst leading), first-line
# indent 0.5 in, 1 in margins, US Letter, single-spaced blocks at 19.8 pt exact, 11 pt footnotes, bold
# centered level-1 and hanging level-2/3 headings, and a centered PAGE footer on the body section only
# (the cover and table of contents are their own section with no footer).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"
FONT='<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif"/>'
cat > "$W/styles.pl" <<'PL'
my $font = shift @ARGV;
my %new = (
  Normal => '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$font<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>',
  BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="228" w:line="385" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>',
  FirstParagraph => '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>',
  Compact => '<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>',
  Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:widowControl/><w:spacing w:before="192" w:after="192" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>',
  Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:widowControl/><w:spacing w:before="192" w:after="192" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
  Heading3 => '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:widowControl/><w:spacing w:before="144" w:after="144" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>',
  BlockText => '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>',
  FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>',
  Table => '<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:uiPriority w:val="59"/><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:tblPr><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="115" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>',
);
# custom paragraph styles used by the markdown filter (mc.lua); single-spaced at the typst single leading
my %custom = (
  Single => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
  Centered => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>',
  Counsel => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Counsel"><w:name w:val="Counsel"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="3168" w:firstLine="0"/></w:pPr></w:style>',
  Signature => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4032" w:firstLine="0"/></w:pPr></w:style>',
  SignatureEnd => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureEnd"><w:name w:val="SignatureEnd"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:keepNext w:val="0"/></w:pPr></w:style>',
  CertPara => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertPara"><w:name w:val="CertPara"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>',
  CaptionCell => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCell"><w:name w:val="CaptionCell"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>',
  TOCLevel1 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCLevel1"><w:name w:val="TOCLevel1"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="276" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>',
  TOCLevel2 => '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCLevel2"><w:name w:val="TOCLevel2"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="276" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720" w:firstLine="0"/></w:pPr></w:style>',
);
local $/;
my $s = <STDIN>;
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$font<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s or die "no docDefaults\n";
for my $id (sort keys %new) {
  my $x = $new{$id}; $x =~ s/\$font/$font/g;
  $s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$x}s or $s =~ s{</w:styles>}{$x</w:styles>}s;
}
my $extra = join "", map { my $x = $custom{$_}; $x =~ s/\$font/$font/g; $x } sort keys %custom;
$s =~ s{</w:styles>}{$extra</w:styles>}s;
print $s;
PL
perl "$W/styles.pl" "$FONT" < word/styles.xml > "$W/styles.new" && mv "$W/styles.new" word/styles.xml
# footer: centered PAGE field (cached result 1); Word and LibreOffice renumber it per section
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center"/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId900" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# body section (the last one): letter, 1 in margins, footer with the page number, numbering from 1
perl -0pi -e 's{<w:sectPr>(.*?)</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId900"/>$1<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:start="1"/></w:sectPr>}s' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: document.xml lacks the r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
