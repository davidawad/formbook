#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, to the form of typst/mssb-motion-brief.typ:
# EB Garamond 12 point (5005-1(a)(2)(G): no smaller than 12 point, footer included), double spacing (24 pt rows),
# US Letter with 1 inch margins, a centred page number in the footer, single-spaced footnotes, and the MSSB
# paragraph styles that the filter (mssb-motion-brief.lua) applies. Run once (needs pandoc, unzip, zip);
# the result is committed. Usage: sh docx/make-reference.sh   (from the doc-type folder)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/ref0.docx")
S="$W/x/word/styles.xml"
DOC="$W/x/word/document.xml"
REL="$W/x/word/_rels/document.xml.rels"
CT="$W/x/[Content_Types].xml"
# 1. Pandoc's defaults: theme fonts become EB Garamond; body paragraphs double spaced, no space between them.
sed -i \
  -e 's#<w:rFonts w:asciiTheme="[a-zA-Z]*" [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#g' \
  -e 's#<w:spacing w:after="200" />#<w:spacing w:after="0" />#' \
  -e 's#<w:spacing w:before="180" w:after="180" />#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" />#' \
  -e 's#<w:spacing w:before="36" w:after="36" />#<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" />#' \
  -e '/w:styleId="FootnoteText"/,/<\/w:style>/ s#<w:qFormat />#<w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr>#' \
  "$S"
# 2. The court's paragraph styles (names are what the filter asks for with custom-style).
sed -i '$d' "$S"
cat >> "$S" << 'STYLES'
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBBody"><w:name w:val="MSSB Body" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" w:left="0" /><w:jc w:val="left" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBSingle"><w:name w:val="MSSB Single" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" w:left="0" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBSingleRight"><w:name w:val="MSSB Single Right" /><w:basedOn w:val="MSSBSingle" /><w:qFormat /><w:pPr><w:jc w:val="right" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBCover"><w:name w:val="MSSB Cover" /><w:basedOn w:val="MSSBSingle" /><w:qFormat /><w:pPr><w:keepNext /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBHeadingCaps"><w:name w:val="MSSB Heading Caps" /><w:basedOn w:val="MSSBBody" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:ind w:firstLine="0" w:left="0" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:caps /></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBHeadingCenter"><w:name w:val="MSSB Heading Center" /><w:basedOn w:val="MSSBBody" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:ind w:firstLine="0" w:left="0" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBHeadingLeft"><w:name w:val="MSSB Heading Left" /><w:basedOn w:val="MSSBBody" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:ind w:firstLine="0" w:left="0" /><w:jc w:val="left" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBHeadingItalic"><w:name w:val="MSSB Heading Italic" /><w:basedOn w:val="MSSBBody" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:ind w:firstLine="0" w:left="0" /><w:jc w:val="left" /></w:pPr><w:rPr><w:b /><w:i /></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBSubItem"><w:name w:val="MSSB Sub Item" /><w:basedOn w:val="MSSBBody" /><w:qFormat /><w:pPr><w:ind w:firstLine="0" w:left="1440" w:hanging="720" /><w:jc w:val="left" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBQuote"><w:name w:val="MSSB Quote" /><w:basedOn w:val="MSSBSingle" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" w:left="1080" w:right="720" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBAddress"><w:name w:val="MSSB Address" /><w:basedOn w:val="MSSBSingle" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBSignature"><w:name w:val="MSSB Signature" /><w:basedOn w:val="MSSBSingle" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:ind w:firstLine="0" w:left="4680" /></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="MSSBHeadingPage"><w:name w:val="MSSB Heading Page" /><w:basedOn w:val="MSSBHeadingCaps" /><w:qFormat /><w:pPr><w:pageBreakBefore /></w:pPr></w:style>
</w:styles>
STYLES
# 3. Page setup and a page-number footer, centred, 12 point. The footer part is linked from the body's section.
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdMssbFooter1" />#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />#' \
  "$DOC"
cat > "$W/x/word/footer1.xml" << 'FOOTER'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
FOOTER
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdMssbFooter1" Target="footer1.xml" /></Relationships>#' "$REL"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT"
rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
