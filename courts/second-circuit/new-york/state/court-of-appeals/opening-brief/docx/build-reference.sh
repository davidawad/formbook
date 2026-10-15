#!/bin/sh
# Builds docx/reference.docx for the NY Court of Appeals opening brief (DOCX engine, docs/DOCX.md).
# From pandoc's default reference, to the form in typst/ny-opening-brief.typ:
#   body EB Garamond 14 pt (500.1(j)); body lines exact 31.4 pt, double spaced (500.1(l));
#   first-line indent 0.5 in; headings single spaced; footnotes 14 pt, single spaced;
#   letter page, 1 in margins; page number centred in the footer (500.1(l)).
#   Sections (set by the filter, ny-opening.lua): cover (footer 0, empty), front matter (footer 1,
#   lower roman), body and addendum (footer 1, arabic from 1). The reference's own sectPr is the
#   last section, so it is the arabic one.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q ../ref.docx

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
SZ='<w:sz w:val="28"/><w:szCs w:val="28"/>'
BODY_LINE='<w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/>'
SINGLE='<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'

# set_style <styleId> <xml>: replaces the whole <w:style> with that id (the default styles span lines)
set_style() {
  ID=$1 NEW=$2 perl -0pi -e 's{<w:style [^>]*w:styleId="$ENV{ID}".*?</w:style>}{$ENV{NEW}}s' word/styles.xml
}
# add_style <xml>: appends a custom style
add_style() {
  NEW=$1 perl -0pi -e 's{</w:styles>}{$ENV{NEW}</w:styles>}' word/styles.xml
}

NEWDEF="<w:docDefaults><w:rPrDefault><w:rPr>$FONT$SZ<w:lang w:val=\"en-US\" w:eastAsia=\"zh-CN\" w:bidi=\"ar-SA\"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>$SINGLE</w:pPr></w:pPrDefault></w:docDefaults>"
NEW=$NEWDEF perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{$ENV{NEW}}s' word/styles.xml

set_style Normal "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\"><w:name w:val=\"Normal\"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine=\"0\"/></w:pPr><w:rPr>$FONT$SZ</w:rPr></w:style>"
# body paragraphs: double spaced, first-line indent 0.5 in, left aligned (the typst form)
set_style BodyText "<w:style w:type=\"paragraph\" w:styleId=\"BodyText\"><w:name w:val=\"Body Text\"/><w:basedOn w:val=\"Normal\"/><w:link w:val=\"BodyTextChar\"/><w:qFormat/><w:pPr>$BODY_LINE<w:ind w:firstLine=\"720\"/><w:jc w:val=\"left\"/></w:pPr></w:style>"
set_style FirstParagraph "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"FirstParagraph\"><w:name w:val=\"First Paragraph\"/><w:basedOn w:val=\"BodyText\"/><w:next w:val=\"BodyText\"/><w:qFormat/></w:style>"
set_style Compact "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Compact\"><w:name w:val=\"Compact\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:ind w:firstLine=\"0\"/></w:pPr></w:style>"
set_style BlockText "<w:style w:type=\"paragraph\" w:styleId=\"BlockText\"><w:name w:val=\"Block Text\"/><w:basedOn w:val=\"BodyText\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"280\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"720\" w:right=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/></w:pPr></w:style>"
set_style FootnoteText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteText\"><w:name w:val=\"Footnote Text\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"FootnoteText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"140\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr><w:rPr>$FONT$SZ</w:rPr></w:style>"
set_style FootnoteBlockText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteBlockText\"><w:name w:val=\"Footnote Block Text\"/><w:basedOn w:val=\"FootnoteText\"/><w:qFormat/></w:style>"

# headings: EB Garamond, black, bold; level 1 centred capitals; levels 2 to 5 numbered by the filter
# ("I.", "A.", "1.", "a.") with a hanging label, as the typst heading-label() does
HKEEP='<w:keepNext/><w:keepLines/>'
set_style Heading1 "<w:style w:type=\"paragraph\" w:styleId=\"Heading1\"><w:name w:val=\"heading 1\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:qFormat/><w:pPr>$HKEEP<w:spacing w:before=\"360\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/><w:outlineLvl w:val=\"0\"/></w:pPr><w:rPr>$FONT<w:b/><w:caps/>$SZ</w:rPr></w:style>"
set_style Heading2 "<w:style w:type=\"paragraph\" w:styleId=\"Heading2\"><w:name w:val=\"heading 2\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$HKEEP<w:spacing w:before=\"240\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"720\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"1\"/></w:pPr><w:rPr>$FONT<w:b/><w:caps/>$SZ</w:rPr></w:style>"
set_style Heading3 "<w:style w:type=\"paragraph\" w:styleId=\"Heading3\"><w:name w:val=\"heading 3\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$HKEEP<w:spacing w:before=\"240\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"1440\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"2\"/></w:pPr><w:rPr>$FONT<w:b/>$SZ</w:rPr></w:style>"
set_style Heading4 "<w:style w:type=\"paragraph\" w:styleId=\"Heading4\"><w:name w:val=\"heading 4\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$HKEEP<w:spacing w:before=\"240\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"2160\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"3\"/></w:pPr><w:rPr>$FONT<w:b/><w:i/>$SZ</w:rPr></w:style>"
set_style Heading5 "<w:style w:type=\"paragraph\" w:styleId=\"Heading5\"><w:name w:val=\"heading 5\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$HKEEP<w:spacing w:before=\"240\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"2160\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"4\"/></w:pPr><w:rPr>$FONT<w:b/><w:i/>$SZ</w:rPr></w:style>"
set_style Hyperlink '<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:basedOn w:val="BodyTextChar"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>'

# borderless tables (the cover and the signature blocks are tables in Word; see docs/DOCX.md)
set_style Table '<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:qFormat/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="144" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>'

# custom paragraph styles used by the filter
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Right\"><w:name w:val=\"Right\"/><w:basedOn w:val=\"Single\"/><w:qFormat/><w:pPr><w:ind w:firstLine=\"0\"/><w:jc w:val=\"right\"/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Designation\"><w:name w:val=\"Designation\"/><w:basedOn w:val=\"Single\"/><w:qFormat/><w:pPr><w:ind w:left=\"4320\" w:firstLine=\"0\"/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Indented\"><w:name w:val=\"Indented\"/><w:basedOn w:val=\"Single\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"720\" w:firstLine=\"0\"/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"CoverTitle\"><w:name w:val=\"Cover Title\"/><w:basedOn w:val=\"Centered\"/><w:qFormat/><w:pPr><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr><w:rPr><w:b/><w:caps/></w:rPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"CoverFirm\"><w:name w:val=\"Cover Firm\"/><w:basedOn w:val=\"Single\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"120\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"left\"/></w:pPr><w:rPr><w:b/><w:caps/></w:rPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"FrontHeadingBreak\"><w:name w:val=\"Front Heading New Page\"/><w:basedOn w:val=\"FrontHeading\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Centered\"><w:name w:val=\"Centered\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Single\"><w:name w:val=\"Single\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"280\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"left\"/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Authority\"><w:name w:val=\"Authority\"/><w:basedOn w:val=\"Single\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"200\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"504\" w:hanging=\"504\" w:firstLine=\"0\"/></w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"FrontHeading\"><w:name w:val=\"Front Heading\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr>$HKEEP<w:spacing w:before=\"240\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr><w:rPr>$FONT<w:b/><w:caps/>$SZ</w:rPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"KeepWithNext\"><w:name w:val=\"Keep With Next\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr>$HKEEP</w:pPr></w:style>"
add_style "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Signature\"><w:name w:val=\"Signature\"/><w:basedOn w:val=\"Single\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"4680\" w:firstLine=\"0\"/></w:pPr></w:style>"
for n in 1 2 3 4; do
  IND=$(( (n - 1) * 720 ))
  add_style "<w:style w:type=\"paragraph\" w:styleId=\"TOC$n\"><w:name w:val=\"toc $n\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"Normal\"/><w:uiPriority w:val=\"39\"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val=\"right\" w:leader=\"dot\" w:pos=\"9350\"/></w:tabs><w:spacing w:before=\"60\" w:after=\"120\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"$IND\" w:firstLine=\"0\"/></w:pPr></w:style>"
done

# footers: 0 = empty (cover), 1 = centred PAGE field (front matter, body, addendum)
cat > word/footer0.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:p></w:ftr>
XML
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer0.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId101" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer0.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# the reference's body: no content, one section (letter, 1 in margins, arabic page numbers from 1)
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId101"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'
NEW="<w:body>$SECT</w:body>" perl -0pi -e 's{<w:body>.*</w:body>}{$ENV{NEW}}s' word/document.xml

for part in '[Content_Types].xml' word/_rels/document.xml.rels word/styles.xml word/document.xml word/footer0.xml word/footer1.xml; do xmllint --noout "$part"; done
cd "$W/pkg" && rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
