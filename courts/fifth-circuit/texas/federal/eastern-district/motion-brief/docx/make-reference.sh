#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document, to the form of ../typst/txed-complaint.typ
# (see ../../README.md and docs/DOCX.md): EB Garamond 13 pt; body double spaced (27.6 pt exact) with a half-inch
# first-line indent and a 27.6 pt gap between blocks; headings bold, centered, capitals; the cover, caption,
# numbered-paragraph and signature styles the txed-complaint.lua filter applies; letter page, 1-inch margins;
# a centered 11 pt page-number footer. Usage: sh docx/make-reference.sh [out.docx]
# Needs pandoc, perl, unzip, zip, xmllint.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"

# Styles: each style below replaces pandoc's of the same id, or is appended.
cat > "$T/styles.pl" <<'PERL'
my $path = shift;
local $/;
open my $fh, '<', $path or die "styles.pl: $path: $!";
my $S = <$fh>;
close $fh;
my $EB = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />};
my $SINGLE = q{<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact" />};
my $DOUBLE_GAP = q{<w:spacing w:before="0" w:after="552" w:line="552" w:lineRule="exact" />};
my $BLOCK_GAP = q{<w:spacing w:before="552" w:after="552" w:line="276" w:lineRule="exact" />};
my %style = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr>$EB<w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr>$DOUBLE_GAP<w:ind w:firstLine="720" /><w:jc w:val="left" /></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /></w:style>},
  Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="552" w:line="276" w:lineRule="exact" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr>$EB<w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>},
  Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="552" w:line="276" w:lineRule="exact" /><w:jc w:val="left" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr>$EB<w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>},
  Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="552" w:line="276" w:lineRule="exact" /><w:jc w:val="left" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr>$EB<w:b /><w:bCs /><w:i /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text" /><w:basedOn w:val="Normal" /><w:next w:val="FootnoteText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact" /></w:pPr><w:rPr>$EB<w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>},
  Table => q{<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table" /><w:uiPriority w:val="99" /><w:tblPr><w:tblInd w:w="0" w:type="dxa" /><w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa" /><w:left w:w="0" w:type="dxa" /><w:bottom w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr></w:style>},
  CourtTitle => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /><w:caps /></w:rPr></w:style>},
  BlockGap => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BlockGap"><w:name w:val="Block Gap" /><w:basedOn w:val="Normal" /><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact" /></w:pPr></w:style>},
  CaptionLine => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="Caption Line" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr>$SINGLE<w:jc w:val="left" /></w:pPr></w:style>},
  CaptionDesignation => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation" /><w:basedOn w:val="CaptionLine" /><w:qFormat /><w:pPr><w:ind w:left="2160" /></w:pPr></w:style>},
  TitleOfPaper => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="TitleOfPaper"><w:name w:val="Title of Paper" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="552" w:after="552" w:line="276" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /><w:caps /></w:rPr></w:style>},
  NumberedParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:tabs><w:tab w:val="left" w:pos="1728" /></w:tabs>$DOUBLE_GAP<w:ind w:firstLine="720" /><w:jc w:val="left" /></w:pPr></w:style>},
  LetteredItem => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="LetteredItem"><w:name w:val="Lettered Item" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440" /></w:tabs>$DOUBLE_GAP<w:ind w:left="1440" w:hanging="720" /><w:jc w:val="left" /></w:pPr></w:style>},
  SignatureBlock => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines />$SINGLE<w:ind w:left="4320" /><w:jc w:val="left" /></w:pPr></w:style>},
  SignatureGap => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureGap"><w:name w:val="Signature Gap" /><w:basedOn w:val="SignatureBlock" /><w:qFormat /></w:style>},
  CertificateHeading => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertificateHeading"><w:name w:val="Certificate Heading" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="552" w:after="552" w:line="276" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style>},
);
for my $id (sort keys %style) {
  my $new = $style{$id};
  if ($S =~ s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$new}s) {
  } else {
    $S =~ s{</w:styles>}{$new\n</w:styles>}s;
  }
}
# Document defaults: EB Garamond 13 pt, no default spacing after.
$S =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$EB<w:sz w:val="26" /><w:szCs w:val="26" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" /></w:pPr></w:pPrDefault></w:docDefaults>}s or die "styles.pl: no docDefaults";
open my $out, '>', $path or die "styles.pl: $path: $!";
print $out $S;
close $out;
PERL
perl "$T/styles.pl" "$W/word/styles.xml"

# Page setup (letter, 1-inch margins) and the page-number footer, as in the Ninth Circuit reference.
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
grep -q 'rIdFooter1' "$W/word/document.xml" || { echo "make-reference.sh: sectPr not found in pandoc's reference" >&2; exit 1; }
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
