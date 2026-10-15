#!/bin/sh
# Build docx/reference.docx: pandoc's default reference.docx with this court's styles, page setup and
# page-number footer. Same file for every doc type of areb; copy it beside each doc type's docx/.
# Usage: sh docx/make-reference.sh [out.docx]   (default: reference.docx beside this script)
# Needs: pandoc, unzip, zip, xmllint (run with PATH="$HOME/tb/bin:$PATH" on the box).
#
# Numbers come from the typst template (../typst/areb-adversary-complaint.typ):
#   page     US Letter, 1 in margins; footer page number centred, 12 pt
#   body     EB Garamond 12 pt, justified, 22.2 pt exact (double-spaced convention, AREB-FORM-004)
#   single   13.2 pt exact (caption, counsel block, signature, quotations)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/base.docx"
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
X="$W/x"
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'

# --- styles ---------------------------------------------------------------------------------
cat > "$X/word/styles.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles $NS>
  <w:docDefaults>
    <w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
  <w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
  <w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
  <w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:tblPr><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders></w:tblPr></w:style>

  <w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="444" w:lineRule="exact"/><w:jc w:val="both"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="288" w:after="240" w:line="444" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="264" w:after="216" w:line="444" w:lineRule="exact"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="192" w:line="444" w:lineRule="exact"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="160" w:after="240" w:line="264" w:lineRule="exact"/><w:ind w:left="720" w:right="720"/><w:jc w:val="both"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="264" w:lineRule="exact"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:basedOn w:val="DefaultParagraphFont"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:basedOn w:val="DefaultParagraphFont"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
  <w:style w:type="character" w:styleId="VerbatimChar"><w:name w:val="Verbatim Char"/><w:basedOn w:val="DefaultParagraphFont"/></w:style>

  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionSingle"><w:name w:val="Caption Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="264" w:lineRule="exact"/><w:jc w:val="left"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCentered"><w:name w:val="Caption Centered"/><w:basedOn w:val="CaptionSingle"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRight"><w:name w:val="Caption Right"/><w:basedOn w:val="CaptionSingle"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionHeading"><w:name w:val="Caption Heading"/><w:basedOn w:val="CaptionCentered"/><w:qFormat/><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCase"><w:name w:val="Caption Case"/><w:basedOn w:val="CaptionSingle"/><w:qFormat/><w:pPr><w:ind w:left="360"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="CaptionSingle"/><w:qFormat/><w:pPr><w:ind w:left="4752"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CertificateBody"><w:name w:val="Certificate Body"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>

  <w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
</w:styles>
EOF

# --- footer: centred PAGE field ---------------------------------------------------------------
cat > "$X/word/footer1.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:fldSimple w:instr=" PAGE "><w:r><w:t>1</w:t></w:r></w:fldSimple></w:p></w:ftr>
EOF

# --- document: empty body and the section (page setup, footer) ---------------------------------
cat > "$X/word/document.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document $NS><w:body><w:p><w:pPr><w:pStyle w:val="BodyText"/></w:pPr></w:p><w:sectPr><w:footerReference w:type="default" r:id="rIdAredFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="800" w:gutter="0"/></w:sectPr></w:body></w:document>
EOF

# --- register the footer part ----------------------------------------------------------------
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdAredFooter1" Target="footer1.xml" /></Relationships>#' "$X/word/_rels/document.xml.rels"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$X/[Content_Types].xml"

# --- check well-formedness, then zip ([Content_Types].xml first) -------------------------------
find "$X" -type f \( -name '*.xml' -o -name '*.rels' \) | while IFS= read -r part; do
  xmllint --noout "$part"
done
rm -f "$OUT"
(cd "$X" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" . -x '[Content_Types].xml')
echo "$OUT"
