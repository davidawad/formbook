#!/bin/sh
# Builds docx/reference.docx for the D.S.C. complaint from pandoc's default reference document (docs/DOCX.md).
# Form (D.S.C. Local Civ. Rule 1.05, the same as typst/scd-complaint.typ): Times New Roman 12 pt (the face the
# rule names; LibreOffice shows it as its metric-compatible Liberation Serif); body double-spaced (w:line 480 auto,
# Word's double) with a half-inch first-line indent; headings single-spaced, bold, centered, capitals for levels 1
# and 2; level 3 centered bold; footnotes and block quotations 12 pt, single-spaced; US Letter, 1-inch margins; the
# page number centered in the footer. Usage: sh docx/make-reference.sh [out.docx]  (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/w"
(cd "$T/w" && unzip -q "$T/default.docx")

cat > "$T/styles.pl" <<'PERL'
my $f = shift;
local $/;
open my $h, '<:encoding(UTF-8)', $f or die "open $f: $!";
my $x = <$h>;
close $h;
my $F = '<w:rFonts w:ascii="Times New Roman" w:eastAsia="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman" />';
my %style = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:widowControl /></w:pPr></w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto" /><w:ind w:firstLine="720" /></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto" /><w:ind w:firstLine="720" /></w:pPr></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:style>},
  Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading1Char" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="288" w:after="216" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr>$F<w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
  Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading2Char" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="288" w:after="216" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr>$F<w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
  Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading3Char" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="144" w:after="216" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr>$F<w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" w:left="720" w:right="720" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
);
for my $id (sort keys %style) {
  my $n = ($x =~ s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$style{$id}}s);
  die "styles.xml: style $id not found\n" unless $n;
}
my $dd = qq{<w:docDefaults><w:rPrDefault><w:rPr>$F<w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>};
(my $n = ($x =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s)) or die "styles.xml: no docDefaults\n";
# Custom paragraph styles used by the Lua filter (scd-complaint.lua).
my $add = join "", map { qq{$_} } (
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtHeading"><w:name w:val="Court Heading" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /><w:caps /></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtHeadingLast"><w:name w:val="Court Heading Last" /><w:basedOn w:val="CourtHeading" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="360" w:line="240" w:lineRule="auto" /></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionText"><w:name w:val="Caption Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="DocumentTitle"><w:name w:val="Document Title" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before="360" w:after="165" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /><w:caps /></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureText"><w:name w:val="Signature Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style>},
);
$x =~ s{</w:styles>}{$add</w:styles>} or die "styles.xml: no end tag\n";
open my $o, '>:encoding(UTF-8)', $f or die "write $f: $!";
print $o $x;
close $o;
PERL
perl "$T/styles.pl" "$T/w/word/styles.xml"

cat > "$T/doc.pl" <<'PERL'
my $f = shift;
local $/;
open my $h, '<:encoding(UTF-8)', $f or die "open $f: $!";
my $x = <$h>;
close $h;
my $sect = qq{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:cols w:space="720" /></w:sectPr>};
(my $n = ($x =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s)) or die "document.xml: no sectPr\n";
open my $o, '>:encoding(UTF-8)', $f or die "write $f: $!";
print $o $x;
close $o;
PERL
perl "$T/doc.pl" "$T/w/word/document.xml"

cat > "$T/w/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$T/w/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$T/w/[Content_Types].xml"
for f in "$T/w/word/styles.xml" "$T/w/word/document.xml" "$T/w/word/footer1.xml" "$T/w/word/_rels/document.xml.rels" "$T/w/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$T/w" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
