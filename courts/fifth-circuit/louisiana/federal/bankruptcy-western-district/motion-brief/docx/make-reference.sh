#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document, to the layout of
# typst/lawb-motion-brief.typ (rules and gaps: ../README.md):
#   EB Garamond 13 pt; body double-spaced at 26 pt exact (the typst pitch); every body paragraph with a 0.5 in
#   first-line indent; lettered items "a." at 0.5 in; headings with a blank double line above and below: level 1 bold,
#   centered; level 2 bold and underlined, at the left; footnotes 13 pt, single-spaced; letter page, 1-inch margins,
#   a centered "- n -" page-number footer.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
W="$T/x"
mkdir "$W"
(cd "$W" && unzip -q "$T/default.docx")

# put_style <styleId> <xml>: replace the style with that id in word/styles.xml, or add it.
put_style() {
  STYLE_ID=$1 STYLE_XML=$2 perl -0777 -i -pe '
    s{<w:style [^>]*w:styleId="\Q$ENV{STYLE_ID}\E"[^>]*>.*?</w:style>}{}s;
    s{</w:styles>}{$ENV{STYLE_XML}</w:styles>}s;
  ' "$W/word/styles.xml"
}

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
DD="<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/><w:lang w:val=\"en-US\" w:eastAsia=\"en-US\" w:bidi=\"ar-SA\"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/></w:pPr></w:pPrDefault></w:docDefaults>"
DD=$DD perl -0777 -i -pe 's{<w:docDefaults>.*?</w:docDefaults>}{$ENV{DD}}s' "$W/word/styles.xml"

put_style Normal '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/></w:pPr><w:rPr>'"$FONT"'<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>'
put_style BodyText '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>'
put_style FirstParagraph '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>'
put_style Compact '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>'
put_style Heading1 '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="520" w:after="520" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>'
put_style Heading2 '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="520" w:after="520" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:u w:val="single"/></w:rPr></w:style>'
put_style FootnoteText '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="104" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>'
put_style BlockText '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>'
put_style ListLetter '<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListLetter"><w:name w:val="List Letter"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>'
# Table: no borders and no header rule (the pandoc default draws a rule under the first row).
put_style Table '<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="59"/><w:tblPr><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="60" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="60" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>'

# Section: letter, 1-inch margins, footer with the page number (the footer part is added below).
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>'
SECT=$SECT perl -0777 -i -pe 's{<w:sectPr[ >].*?</w:sectPr>}{$ENV{SECT}}s' "$W/word/document.xml"

cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:r><w:t xml:space="preserve">- </w:t></w:r><w:fldSimple w:instr=" PAGE "><w:r><w:t>1</w:t></w:r></w:fldSimple><w:r><w:t xml:space="preserve"> -</w:t></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0777 -i -pe 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"

for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do
  xmllint --noout "$f"
done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
