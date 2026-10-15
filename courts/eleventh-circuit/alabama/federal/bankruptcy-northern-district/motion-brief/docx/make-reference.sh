#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../docs/DOCX.md). The form matches
# typst/alnb-adversary-complaint.typ: EB Garamond 12 pt; body double-spaced (24 pt exact) with a half-inch first-line
# indent and 0.9-line gaps between paragraphs; court title, caption and signature block single-spaced; headings bold;
# footnotes 10 pt single-spaced; letter page with 1-inch margins; a centered page-number footer.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
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
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />'
# Styles: drop the ids this reference redefines, then append the new definitions.
perl -0pi -e '
  my $font = q{'"$FONT"'};
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{$font}sg;
  s{<w:rFonts w:asciiTheme="majorHAnsi".*?/>}{$font}sg;
  for my $id (qw(Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 FootnoteText Table)) {
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{}s;
  }
  my $sz = q{<w:sz w:val="24" /><w:szCs w:val="24" />};
  my $new = qq{
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="left" /></w:pPr><w:rPr>$font $sz</w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="216" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="216" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="216" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" />$sz</w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="216" w:after="216" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:firstLine="0" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" />$sz</w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="216" w:after="216" w:line="240" w:lineRule="auto" /><w:ind w:left="1440" w:firstLine="0" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" />$sz</w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text" /><w:basedOn w:val="Normal" /><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr></w:style>
  <w:style w:type="table" w:styleId="Table"><w:name w:val="Table" /><w:uiPriority w:val="59" /><w:tblPr><w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa" /><w:left w:w="0" w:type="dxa" /><w:bottom w:w="0" w:type="dxa" /><w:right w:w="115" w:type="dxa" /></w:tblCellMar></w:tblPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:jc w:val="center" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionBlock"><w:name w:val="Caption Block" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation" /><w:basedOn w:val="CaptionBlock" /><w:qFormat /><w:pPr><w:ind w:left="3240" w:firstLine="0" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="DocumentTitle"><w:name w:val="Document Title" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before="240" w:after="360" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:left="4680" w:firstLine="0" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Spacer"><w:name w:val="Spacer" /><w:basedOn w:val="Normal" /><w:pPr><w:spacing w:before="0" w:after="216" w:line="240" w:lineRule="auto" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionMid"><w:name w:val="Caption Mid" /><w:basedOn w:val="CaptionBlock" /><w:pPr><w:jc w:val="center" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="ServedParty"><w:name w:val="Served Party" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:firstLine="0" /></w:pPr></w:style>
  };
  s{(</w:styles>)}{$new$1}s;
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0" />}s;
' "$W/word/document.xml"
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
