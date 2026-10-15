#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the NMIB motion with memorandum.
# Mandated form as set in typst/nmib-motion-brief.typ (the parameters there are the source):
#   EB Garamond 13 pt (serif, vendored); exact 24 pt (double) line spacing on the numbered lines;
#   first-line indent 0.5 in; letter page; margins top 1.5 in, bottom 1 in, left 1.3 in, right 1 in;
#   pleading rules (double at the left edge of the text, single at the right); line numbers 1 to 24 in the
#   left margin (Word section line numbering, restart each page); page number centered in the footer, 11 pt;
#   footnote text 13 pt, single spaced. Headings: level 1 centered capitals; levels 2 to 4 bold with a hanging
#   label. The body section numbers pages 1, 2, ...; the tables of contents and authorities use i, ii, ...
#   (the cover has no page number). The TOC field is updated on open (w:updateFields in settings.xml).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx

# replace (or add) one style: $1 = styleId, $2 = full <w:style> element
set_style() {
  ID=$1 NEW=$2 perl -0pi -e 'my $id = $ENV{ID}; my $n = $ENV{NEW};
    if (!s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$n}s) { s{</w:styles>}{$n</w:styles>}s }' word/styles.xml
}

# document defaults: the body font and size everywhere (no theme fonts)
DEFAULTS="<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/><w:lang w:val=\"en-US\" w:eastAsia=\"en-US\" w:bidi=\"ar-SA\"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/></w:pPr></w:pPrDefault></w:docDefaults>"
DEFAULTS="$DEFAULTS" perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{$ENV{DEFAULTS}}s' word/styles.xml

EXACT='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
PITCH_ABOVE='<w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/>'
set_style Normal "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\"><w:name w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:jc w:val=\"left\"/></w:pPr><w:rPr>$FONT<w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# running text: double spaced (24 pt exact), first-line indent 0.5 in
set_style BodyText "<w:style w:type=\"paragraph\" w:styleId=\"BodyText\"><w:name w:val=\"Body Text\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr>$EXACT<w:ind w:firstLine=\"720\"/></w:pPr></w:style>"
set_style FirstParagraph "<w:style w:type=\"paragraph\" w:styleId=\"FirstParagraph\"><w:name w:val=\"First Paragraph\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr>$EXACT<w:ind w:firstLine=\"720\"/></w:pPr></w:style>"
set_style Compact "<w:style w:type=\"paragraph\" w:styleId=\"Compact\"><w:name w:val=\"Compact\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr>$EXACT<w:ind w:firstLine=\"0\"/></w:pPr></w:style>"
# headings: a numbered line above each heading, kept with the paragraph after it
set_style Heading1 "<w:style w:type=\"paragraph\" w:styleId=\"Heading1\"><w:name w:val=\"heading 1\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$PITCH_ABOVE<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/><w:outlineLvl w:val=\"0\"/></w:pPr><w:rPr><w:b/><w:caps/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# the tables of contents and authorities are headings that are not in the TOC field
set_style TOCHeading "<w:style w:type=\"paragraph\" w:styleId=\"TOCHeading\"><w:name w:val=\"TOC Heading\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"39\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$PITCH_ABOVE<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr><w:rPr><w:b/><w:caps/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# levels 2 to 4: bold, the label at its level's indent and the text after a half-inch tab (hanging indent)
set_style Heading2 "<w:style w:type=\"paragraph\" w:styleId=\"Heading2\"><w:name w:val=\"heading 2\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$PITCH_ABOVE<w:ind w:left=\"720\" w:hanging=\"720\"/><w:outlineLvl w:val=\"1\"/></w:pPr><w:rPr><w:b/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
set_style Heading3 "<w:style w:type=\"paragraph\" w:styleId=\"Heading3\"><w:name w:val=\"heading 3\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$PITCH_ABOVE<w:ind w:left=\"1440\" w:hanging=\"720\"/><w:outlineLvl w:val=\"2\"/></w:pPr><w:rPr><w:b/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
set_style Heading4 "<w:style w:type=\"paragraph\" w:styleId=\"Heading4\"><w:name w:val=\"heading 4\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$PITCH_ABOVE<w:ind w:left=\"2160\" w:hanging=\"720\"/><w:outlineLvl w:val=\"3\"/></w:pPr><w:rPr><w:b/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# footnotes: 13 pt, single spaced
set_style FootnoteText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteText\"><w:name w:val=\"footnote text\"/><w:basedOn w:val=\"Normal\"/><w:uiPriority w:val=\"99\"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before=\"0\" w:after=\"80\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr><w:rPr><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# custom styles for the cover, caption, authorities and signature lines: single spaced
set_style Centered "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Centered\"><w:name w:val=\"Centered\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr></w:style>"
set_style Single "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Single\"><w:name w:val=\"Single\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr></w:style>"

# footer: the page number, centered, 11 pt (PAGE field; cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId900" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# update fields on open, so the TOC page numbers appear in Word (settings order: before footnotePr)
perl -0pi -e 's{<w:footnotePr>}{<w:updateFields w:val="true"/><w:footnotePr>}' word/settings.xml

# final section (the body and the signature): letter, pleading margins 1.5 in top, 1 in bottom, rules, line
# numbers 1 to 24 restarting each page, arabic page numbers from 1
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId900"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="1440" w:left="1872" w:header="720" w:footer="720" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:lnNumType w:countBy="1" w:distance="576" w:restart="newPage"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>'
SECT="$SECT" perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{}s; s{</w:body>}{$ENV{SECT}</w:body>}s' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/settings.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
