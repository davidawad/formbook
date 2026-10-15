#!/bin/sh
# Builds docx/reference.docx for the msnd motion brief from pandoc's default reference document (docs/DOCX.md).
# It sets what typst/msnd-motion-brief.typ sets:
#   EB Garamond 12 pt (L.U.Civ.R. 7(b)(5)(B) names no face; docs/FONTS.md); text double-spaced (24 pt exact) with a
#   half-inch first-line indent; block quotations indented half an inch on both sides, double-spaced; headings bold
#   (level 1 centered in capitals, level 2 at the left, level 3 bold italic); footnotes 11 pt, single-spaced; letter
#   paper with 1-inch margins (L.U.Civ.R. 7(b)(5)(A)); a page number centered in the footer.
# Usage: sh docx/make-reference.sh [out.docx]     (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/w"
(cd "$T/w" && unzip -q "$T/default.docx")
W="$T/w"

# Styles. Pandoc writes these style IDs; any ID not listed here is created by pandoc from its own defaults.
cat > "$W/word/styles.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />
        <w:sz w:val="24" />
        <w:szCs w:val="24" />
        <w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" />
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:widowControl />
        <w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" />
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal" />
    <w:qFormat />
  </w:style>
  <w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont">
    <w:name w:val="Default Paragraph Font" />
    <w:uiPriority w:val="1" />
    <w:semiHidden />
    <w:unhideWhenUsed />
  </w:style>
  <w:style w:type="table" w:default="1" w:styleId="TableNormal">
    <w:name w:val="Normal Table" />
    <w:uiPriority w:val="99" />
    <w:semiHidden />
    <w:unhideWhenUsed />
    <w:tblPr>
      <w:tblInd w:w="0" w:type="dxa" />
      <w:tblCellMar>
        <w:top w:w="0" w:type="dxa" />
        <w:left w:w="108" w:type="dxa" />
        <w:bottom w:w="0" w:type="dxa" />
        <w:right w:w="108" w:type="dxa" />
      </w:tblCellMar>
    </w:tblPr>
  </w:style>
  <!-- Body text: double-spaced, first-line indent 0.5 in (typst: para-indent, body-leading 24 pt). -->
  <w:style w:type="paragraph" w:styleId="BodyText">
    <w:name w:val="Body Text" />
    <w:basedOn w:val="Normal" />
    <w:qFormat />
    <w:pPr>
      <w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />
      <w:ind w:firstLine="720" />
    </w:pPr>
  </w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph">
    <w:name w:val="First Paragraph" />
    <w:basedOn w:val="BodyText" />
    <w:next w:val="BodyText" />
    <w:qFormat />
  </w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact">
    <w:name w:val="Compact" />
    <w:basedOn w:val="BodyText" />
    <w:qFormat />
    <w:pPr>
      <w:ind w:firstLine="0" />
    </w:pPr>
  </w:style>
  <!-- List items (typst: enum indent 0.5 in, body indent 0.4 in): "1." at 0.5 in, the text at 0.9 in. -->
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerItem">
    <w:name w:val="Prayer Item" />
    <w:basedOn w:val="BodyText" />
    <w:qFormat />
    <w:pPr>
      <w:tabs>
        <w:tab w:val="left" w:pos="1296" />
      </w:tabs>
      <w:ind w:left="1296" w:firstLine="-576" />
    </w:pPr>
  </w:style>
  <!-- Block quotations: indented half an inch on both sides, double-spaced, no first-line indent. -->
  <w:style w:type="paragraph" w:styleId="BlockText">
    <w:name w:val="Block Text" />
    <w:basedOn w:val="BodyText" />
    <w:next w:val="BodyText" />
    <w:uiPriority w:val="9" />
    <w:unhideWhenUsed />
    <w:qFormat />
    <w:pPr>
      <w:ind w:left="720" w:right="720" w:firstLine="0" />
    </w:pPr>
  </w:style>
  <!-- Headings: kept with the next paragraph; one double-spaced line above (typst: heading-block above body-leading,
       below 0). Level 1 is centered (the filter capitalizes its text, as typst upper() does); level 2 bold at the left;
       level 3 bold italic at the left. -->
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1" />
    <w:basedOn w:val="Normal" />
    <w:next w:val="BodyText" />
    <w:uiPriority w:val="9" />
    <w:qFormat />
    <w:pPr>
      <w:keepNext />
      <w:keepLines />
      <w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact" />
      <w:jc w:val="center" />
      <w:outlineLvl w:val="0" />
    </w:pPr>
    <w:rPr>
      <w:b />
      <w:bCs />
      <w:color w:val="000000" />
      <w:sz w:val="24" />
      <w:szCs w:val="24" />
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading2">
    <w:name w:val="heading 2" />
    <w:basedOn w:val="Normal" />
    <w:next w:val="BodyText" />
    <w:uiPriority w:val="9" />
    <w:unhideWhenUsed />
    <w:qFormat />
    <w:pPr>
      <w:keepNext />
      <w:keepLines />
      <w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact" />
      <w:outlineLvl w:val="1" />
    </w:pPr>
    <w:rPr>
      <w:b />
      <w:bCs />
      <w:color w:val="000000" />
      <w:sz w:val="24" />
      <w:szCs w:val="24" />
    </w:rPr>
  </w:style>
  <w:style w:type="paragraph" w:styleId="Heading3">
    <w:name w:val="heading 3" />
    <w:basedOn w:val="Normal" />
    <w:next w:val="BodyText" />
    <w:uiPriority w:val="9" />
    <w:unhideWhenUsed />
    <w:qFormat />
    <w:pPr>
      <w:keepNext />
      <w:keepLines />
      <w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact" />
      <w:outlineLvl w:val="2" />
    </w:pPr>
    <w:rPr>
      <w:b />
      <w:bCs />
      <w:i />
      <w:iCs />
      <w:color w:val="000000" />
      <w:sz w:val="24" />
      <w:szCs w:val="24" />
    </w:rPr>
  </w:style>
  <!-- Footnotes: 11 pt (L.U.Civ.R. 7(b)(5)(B): 11-point or larger), single-spaced. -->
  <w:style w:type="paragraph" w:styleId="FootnoteText">
    <w:name w:val="Footnote Text" />
    <w:basedOn w:val="Normal" />
    <w:uiPriority w:val="99" />
    <w:unhideWhenUsed />
    <w:pPr>
      <w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto" />
    </w:pPr>
    <w:rPr>
      <w:sz w:val="22" />
      <w:szCs w:val="22" />
    </w:rPr>
  </w:style>
  <w:style w:type="character" w:styleId="FootnoteReference">
    <w:name w:val="Footnote Reference" />
    <w:uiPriority w:val="99" />
    <w:unhideWhenUsed />
    <w:rPr>
      <w:vertAlign w:val="superscript" />
    </w:rPr>
  </w:style>
</w:styles>
XML

# Section: letter paper, 1-inch margins, footer 0.5 in from the foot of the page (the page number sits in the margin).
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:cols w:space="720" /></w:sectPr>}s' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"

for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do
  xmllint --noout "$f"
done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" .)
echo "$OUT"
