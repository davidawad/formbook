#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the NMIB adversary complaint.
# Mandated form as set in typst/nmib-adversary-complaint.typ (the parameters there are the source):
#   EB Garamond 13 pt (serif, vendored); exact 24 pt (double) line spacing on the numbered lines;
#   first-line indent 0.5 in; letter page; margins top 1.5 in, bottom 1.5 in (holds the footer),
#   left 1.3 in, right 1 in; pleading rules (double at the left edge of the text, single at the right);
#   line numbers 1 to 24 in the left margin (Word section line numbering, restart each page);
#   page number centered in the footer, 10 pt. Footnote text 13 pt, single spaced.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx

# replace (or add) one paragraph style: $1 = styleId, $2 = full <w:style> element
set_style() {
  ID=$1 NEW=$2 perl -0pi -e 'my $id = $ENV{ID}; my $n = $ENV{NEW};
    if (!s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$n}s) { s{</w:styles>}{$n</w:styles>}s }' word/styles.xml
}

# document defaults: the body font and size everywhere (no theme fonts)
DEFAULTS="<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/><w:lang w:val=\"en-US\" w:eastAsia=\"en-US\" w:bidi=\"ar-SA\"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/></w:pPr></w:pPrDefault></w:docDefaults>"
DEFAULTS="$DEFAULTS" perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{$ENV{DEFAULTS}}s' word/styles.xml

EXACT='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
set_style Normal "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\"><w:name w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:jc w:val=\"left\"/></w:pPr><w:rPr>$FONT<w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# numbered allegations and running text: double spaced (24 pt exact), first-line indent 0.5 in
for id in BodyText FirstParagraph; do
  set_style $id "<w:style w:type=\"paragraph\" w:styleId=\"$id\"><w:name w:val=\"$( [ $id = BodyText ] && echo 'Body Text' || echo 'First Paragraph')\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr>$EXACT<w:ind w:firstLine=\"720\"/></w:pPr></w:style>"
done
set_style Compact "<w:style w:type=\"paragraph\" w:customStyle=\"0\" w:styleId=\"Compact\"><w:name w:val=\"Compact\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr>$EXACT<w:ind w:firstLine=\"0\"/></w:pPr></w:style>"
# headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the margin.
# Every heading is one double-spaced line and is kept with the paragraph after it.
set_style Heading1 "<w:style w:type=\"paragraph\" w:styleId=\"Heading1\"><w:name w:val=\"heading 1\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$EXACT<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/><w:outlineLvl w:val=\"0\"/></w:pPr><w:rPr><w:b/><w:caps/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
set_style Heading2 "<w:style w:type=\"paragraph\" w:styleId=\"Heading2\"><w:name w:val=\"heading 2\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$EXACT<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/><w:outlineLvl w:val=\"1\"/></w:pPr><w:rPr><w:b/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
set_style Heading3 "<w:style w:type=\"paragraph\" w:styleId=\"Heading3\"><w:name w:val=\"heading 3\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:uiPriority w:val=\"9\"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$EXACT<w:ind w:firstLine=\"0\"/><w:outlineLvl w:val=\"2\"/></w:pPr><w:rPr><w:b/><w:i/><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# footnotes: 13 pt, single spaced
set_style FootnoteText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteText\"><w:name w:val=\"footnote text\"/><w:basedOn w:val=\"Normal\"/><w:uiPriority w:val=\"99\"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before=\"0\" w:after=\"80\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr><w:rPr><w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr></w:style>"
# custom styles for the cover, caption, signature and footer lines: single spaced
set_style Centered "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Centered\"><w:name w:val=\"Centered\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr></w:style>"
set_style Single "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Single\"><w:name w:val=\"Single\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr></w:style>"

# footer: the page number, centered, 10 pt (PAGE field; cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId900" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# body section (the final section; the filter writes the cover as its own section): letter, pleading margins,
# pleading rules (double left, single right, offset from the text), line numbers 1-24 restarting each page
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId900"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="2160" w:left="1872" w:header="720" w:footer="720" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders><w:lnNumType w:countBy="1" w:distance="576" w:restart="newPage"/><w:cols w:space="720"/></w:sectPr>'
# pandoc's default body carries a sectPr of its own (footnote numbering only); replace it, one body sectPr only
SECT="$SECT" perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{}s; s{</w:body>}{$ENV{SECT}</w:body>}s' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
