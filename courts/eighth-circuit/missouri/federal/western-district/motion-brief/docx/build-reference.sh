#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: the styles and page setup of the typst
# template (typst/mowd-motion-brief.typ), in Word-native features (docs/DOCX.md).
#   body: EB Garamond 13 pt, exact 26 pt line pitch (double spacing), 0.5 in first-line indent
#   single: exact 15 pt (the typst single-leading), caption, contents, authorities and signature lines
#   page: US Letter, 1 in margins; one footer part (centered PAGE field). The sections of the document
#   (cover, roman front matter, arabic body) are set in mowd-motion-brief.lua; the number format is
#   per section, so the footer is the same in every section that has it.
# Style names equal the custom-style names the filter uses (pandoc matches custom-style by name).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx
# Replace the styles this filter uses, then append the court's own paragraph styles.
STYLES="Normal BodyText FirstParagraph Compact Table BlockText FootnoteText"
for id in $STYLES; do
  ID=$id perl -0pi -e 's{<w:style [^>]*w:styleId="$ENV{ID}"[^>]*>.*?</w:style>}{}s' word/styles.xml
done
# Document defaults: EB Garamond 13 pt, English (US).
perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>}s' word/styles.xml
STYLE_XML='
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="130" w:line="300" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="26"/></w:rPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdCourtTitle"><w:name w:val="MowdCourtTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdCourtTitleLast"><w:name w:val="MowdCourtTitleLast"/><w:basedOn w:val="MowdCourtTitle"/><w:qFormat/><w:pPr><w:keepNext w:val="0"/><w:spacing w:after="527"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdDivision"><w:name w:val="MowdDivision"/><w:basedOn w:val="MowdCourtTitle"/><w:qFormat/><w:pPr><w:keepNext w:val="0"/><w:spacing w:before="130" w:after="527"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdCaptionLine"><w:name w:val="MowdCaptionLine"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdCaptionRight"><w:name w:val="MowdCaptionRight"/><w:basedOn w:val="MowdCaptionLine"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdCoverTitle"><w:name w:val="MowdCoverTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="527" w:after="527" w:line="520" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdBodyParaKeep"><w:name w:val="MowdBodyParaKeep"/><w:basedOn w:val="MowdBodyPara"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdBodyPara"><w:name w:val="MowdBodyPara"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="140" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdHeadingCaps"><w:name w:val="MowdHeadingCaps"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="140" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdHeadingCapsBreak"><w:name w:val="MowdHeadingCapsBreak"/><w:basedOn w:val="MowdHeadingCaps"/><w:qFormat/><w:pPr><w:pageBreakBefore/><w:spacing w:before="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdHeadingNum1"><w:name w:val="MowdHeadingNum1"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="140" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdHeadingNum2"><w:name w:val="MowdHeadingNum2"/><w:basedOn w:val="MowdHeadingNum1"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdHeadingNum3"><w:name w:val="MowdHeadingNum3"/><w:basedOn w:val="MowdHeadingNum1"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="2160"/></w:tabs><w:ind w:left="2160" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdHeadingNum4"><w:name w:val="MowdHeadingNum4"/><w:basedOn w:val="MowdHeadingNum1"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="2880"/></w:tabs><w:ind w:left="2880" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdPageTitle"><w:name w:val="MowdPageTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="351" w:line="520" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdPageTitleBreak"><w:name w:val="MowdPageTitleBreak"/><w:basedOn w:val="MowdPageTitle"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdToaGroup"><w:name w:val="MowdToaGroup"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="130" w:line="300" w:lineRule="exact"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdEntryCell"><w:name w:val="MowdEntryCell"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdEntryPage"><w:name w:val="MowdEntryPage"/><w:basedOn w:val="MowdEntryCell"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdEntryGap"><w:name w:val="MowdEntryGap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="130" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdBlockQuote"><w:name w:val="MowdBlockQuote"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="140" w:line="300" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdListItem"><w:name w:val="MowdListItem"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1080"/></w:tabs><w:spacing w:before="0" w:after="140" w:line="520" w:lineRule="exact"/><w:ind w:left="1080" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdSpacer"><w:name w:val="MowdSpacer"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="351" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdSpacerKeep"><w:name w:val="MowdSpacerKeep"/><w:basedOn w:val="MowdSpacer"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdSigRespect"><w:name w:val="MowdSigRespect"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdSigSigner"><w:name w:val="MowdSigSigner"/><w:basedOn w:val="MowdSigRespect"/><w:qFormat/><w:pPr><w:spacing w:before="351" w:after="130"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="MowdSigLine"><w:name w:val="MowdSigLine"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/></w:pPr></w:style>
'
ESC=$(printf '%s' "$STYLE_XML" | tr -d '\n')
ESC=$ESC perl -0pi -e 's{</w:styles>}{$ENV{ESC}</w:styles>}' word/styles.xml
# Footer: centered PAGE field. Its number format is set by the section (pgNumType), not here.
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# Final section (the body): letter, 1 in margins, the page-number footer, arabic numbering from 1.
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: document.xml has no r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
