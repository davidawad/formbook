#!/bin/sh
# Builds docx/reference.docx for the arwb motion brief from pandoc's default reference.
# The layout is the one in typst/arwb-motion-brief.typ: EB Garamond 13 pt, double spacing (exact 24 pt),
# 0.5 in first-line indent, 1 in margins on US Letter, a centred plain page number (the typst template's
# footer), argument headings with a hanging label, and single-spaced court, caption, signature and
# certificate lines (exact 15.6 pt). Gaps between blocks are paragraph spacing in the styles, not empty
# paragraphs (pandoc drops those).
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, perl, unzip, zip, xmllint on PATH)
# Every edit is checked: a substitution that does not apply stops the build.
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# Replace the style $1 (a styleId) with the definition in $W/style-$1.xml; a style that is not there is added.
replace_style() {
  perl -0pi -e 's{<w:style [^>]*w:styleId="'"$1"'"[^>]*>.*?</w:style>\s*}{}s' word/styles.xml
  NEW=$(cat "$W/style-$1.xml") perl -0pi -e 's{</w:styles>}{$ENV{NEW}</w:styles>}' word/styles.xml
}
# A custom paragraph style: $1 styleId, $2 name, $3 basedOn, $4 pPr children (schema order), $5 rPr children
para_style() {
  cat > "$W/style-$1.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="$1"><w:name w:val="$2"/><w:basedOn w:val="$3"/><w:qFormat/><w:pPr>$4</w:pPr><w:rPr>$5</w:rPr></w:style>
XML
  replace_style "$1"
}

# docDefaults: the body face and size for every style that does not set its own
perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s' word/styles.xml
grep -q 'w:ascii="EB Garamond"' word/styles.xml || { echo "build-reference: docDefaults not replaced" >&2; exit 1; }

# The exact line pitches: double = 24 pt (480 twips), single = 15.6 pt (312), as the typst template measures them.
DOUBLE='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
SINGLE='<w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/>'
FIRST='<w:ind w:left="0" w:right="0" w:firstLine="720"/>'
HALF='<w:spacing w:before="156" w:after="0" w:line="312" w:lineRule="exact"/>'
TWO='<w:spacing w:before="624" w:after="0" w:line="312" w:lineRule="exact"/>'

perl -0pi -e 's{<w:style w:type="paragraph" w:default="1" w:styleId="Normal">.*?</w:style>}{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>'"$SINGLE"'</w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>}s' word/styles.xml
para_style BodyText "Body Text" Normal "$DOUBLE$FIRST<w:jc w:val=\"left\"/>" ""
para_style FirstParagraph "First Paragraph" BodyText "" ""
# the last paragraph before the signature block keeps with it (a signature is never alone at the top of a page)
para_style BodyTextKeep "Body Text Keep" BodyText "<w:keepNext/>" ""
para_style Compact "Compact" Normal "$SINGLE" ""
# the body: argument headings (a hanging label), lettered factor items, centred section heading (certificate)
para_style ArgumentHeading "Argument Heading" Normal '<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs>'"$DOUBLE"'<w:ind w:left="720" w:right="0" w:hanging="720"/>' '<w:b/><w:bCs/><w:caps/>'
para_style FactorItem "Factor Item" BodyText '<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs>'"$DOUBLE"'<w:ind w:left="1440" w:right="0" w:hanging="720"/>' ""
para_style SectionHeading "Section Heading" Normal "<w:keepNext/><w:keepLines/>$DOUBLE<w:jc w:val=\"center\"/>" '<w:b/><w:bCs/><w:caps/>'
# the cover: court title (bold, the last line leaves the gap to the caption), caption, title of the paper
para_style CourtTitle "Court Title" Normal "$SINGLE<w:jc w:val=\"center\"/>" ""
para_style CourtTitleLast "Court Title Last" CourtTitle '<w:spacing w:before="0" w:after="720" w:line="312" w:lineRule="exact"/>' ""
para_style Caption "Caption" Normal "$SINGLE" ""
para_style CaptionIndent "Caption Indent" Normal "$SINGLE<w:ind w:left=\"1296\" w:right=\"0\" w:firstLine=\"0\"/>" ""
para_style CaptionRight "Caption Right" Caption '<w:ind w:left="288" w:right="0" w:firstLine="0"/>' ""
para_style DocumentTitle "Document Title" Normal '<w:keepNext/><w:spacing w:before="720" w:after="0" w:line="480" w:lineRule="exact"/><w:jc w:val="center"/>' '<w:b/><w:bCs/><w:caps/>'
# the signature block and the certificate: single spaced at 3.25 in, the lines keep together
para_style Signature "Signature" Normal "$SINGLE<w:ind w:left=\"4680\" w:right=\"0\" w:firstLine=\"0\"/>" ""
para_style SignatureKeep "Signature Keep" Signature "<w:keepNext/>" ""
para_style SignatureLead "Signature Lead" Signature '<w:keepNext/><w:spacing w:before="312" w:after="156" w:line="312" w:lineRule="exact"/>' ""
para_style SignatureGap "Signature Gap" Signature '<w:keepNext/><w:spacing w:before="720" w:after="0" w:line="312" w:lineRule="exact"/>' ""
para_style CertificateHeading "Certificate Heading" SectionHeading '<w:spacing w:before="312" w:after="0" w:line="480" w:lineRule="exact"/>' ""
para_style Recipient "Recipient" Normal "<w:keepNext/>$SINGLE<w:ind w:left=\"720\" w:right=\"0\" w:firstLine=\"0\"/>" ""
para_style Footer "Footer" Normal "$SINGLE<w:jc w:val=\"center\"/>" ""
# the table style used by the caption: no borders, no cell margins (the caption columns sit on the text grid)
cat > "$W/style-Table.xml" <<'XML'
<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
XML
replace_style Table

# footer: the page number, centred, plain (typst/arwb-motion-brief.typ, page-footer)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# section: US Letter, 1 in margins, the footer; the footnote numbering restart stays as pandoc wrote it
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' word/document.xml

# every edit must have landed
for needle in 'w:styleId="ArgumentHeading"' 'w:styleId="FactorItem"' 'w:styleId="CourtTitleLast"' 'w:styleId="CaptionRight"' 'w:styleId="SignatureGap"' 'w:styleId="Table"'; do
  grep -q "$needle" word/styles.xml || { echo "build-reference: $needle missing" >&2; exit 1; }
done
grep -q 'r:id="rId100"' word/document.xml || { echo "build-reference: section footer not set" >&2; exit 1; }
grep -q 'w:pgMar w:top="1440"' word/document.xml || { echo "build-reference: page margins not set" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$part"
done

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
