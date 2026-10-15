#!/bin/sh
# Builds docx/reference.docx for the JPML motion-brief (DOCX engine, docs/DOCX.md) from pandoc's default
# reference: EB Garamond 12 pt (the typst template's face and size, JPML-FORM-002), body text exactly 24 pt
# (double spaced, JPML-FORM-003) with a 0.5 in first-line indent, single spacing elsewhere, footnotes 12 pt
# single spaced, letter paper with 1 in margins, and two footers: the page number (PAGE field) and an empty one
# (the memorandum cover is unnumbered). The page-number format and start are set per section in the body
# (docx/jpml.lua); the final section (the memorandum body) is set here.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx
# 1. document defaults: EB Garamond 12 pt, single, no space after
perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s' word/styles.xml
# 2. replace the paragraph styles the markdown uses (pandoc maps them: Body Text, First Paragraph, Compact, footnote text)
for id in Normal BodyText FirstParagraph Compact FootnoteText; do
  perl -0pi -e "s{<w:style [^>]*w:styleId=\"$id\".*?</w:style>}{}s" word/styles.xml
done
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style></w:styles>}s' word/styles.xml
# 3. custom heading styles (JPML Heading 2..5): single spaced, 12 pt above and below, keep with next,
#    hanging label: level L starts its text at (L-1) half inches, the label hangs in the first half inch
for L in 2 3 4 5; do
  left=$(( (L - 1) * 720 ))
  perl -0pi -e "s{</w:styles>}{<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"JPMLHeading$L\"><w:name w:val=\"JPML Heading $L\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before=\"240\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"$left\" w:hanging=\"720\"/></w:pPr></w:style></w:styles>}s" word/styles.xml
done
xmllint --noout word/styles.xml
# 4. footers: the page number (PAGE field; the format comes from the section), and an empty one
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > word/footer2.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId101" Target="footer2.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# 5. final section (the memorandum body, arabic from 1): letter, 1 in margins, page-number footer
sed -i 's|</w:body>|<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr></w:body>|' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
# zip with libzip's ziptool (no zip(1) on this box); [Content_Types].xml first, then every part
set -- add_file '[Content_Types].xml' "$PWD/[Content_Types].xml" 0 0
for f in $(cd "$W/pkg" && find _rels docProps word -type f | sort); do
  set -- "$@" add_file "$f" "$PWD/$f" 0 0
done
ziptool -n "$OUT" "$@" > /dev/null
unzip -tq "$OUT" > /dev/null
echo "$OUT"
