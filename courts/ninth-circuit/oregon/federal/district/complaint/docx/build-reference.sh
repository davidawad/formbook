#!/bin/sh
# Builds docx/reference.docx for the D. Or. complaint (docs/DOCX.md). Starts from pandoc's default reference and
# replaces its styles with the styles of the typst template (ord-complaint.typ): EB Garamond 13 pt, double spacing as
# an exact 24 pt line (480 twips), single spacing as an exact 13 pt line (260 twips), one-inch margins on all sides,
# letter size, and a footer (footer1.xml) with "@FOOTER_TITLE@ - n" (a PAGE field), 12 pt, left aligned.
# No pleading line numbers and no rules: LR 10-1(d) as the template reads it (see ../README.md).
# render.sh fills @FOOTER_TITLE@ from the sample's footer_title.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, xmllint, perl)
set -eu
OUT=$1
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

cat > "$W/styles-new.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="260" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="31"/><w:szCs w:val="31"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="260" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSingle"><w:name w:val="Pleading Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="260" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingCentered"><w:name w:val="Pleading Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingBody"><w:name w:val="Pleading Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingBodyKeep"><w:name w:val="Pleading Body Keep"/><w:basedOn w:val="PleadingBody"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingLetterKeep"><w:name w:val="Pleading Letter Keep"/><w:basedOn w:val="PleadingLetter"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingFlush"><w:name w:val="Pleading Flush"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingLetter"><w:name w:val="Pleading Letter"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:ind w:left="1296" w:hanging="576" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingQuote"><w:name w:val="Pleading Quote"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingCaption"><w:name w:val="Pleading Caption"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSignature"><w:name w:val="Pleading Signature"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:firstLine="0"/></w:pPr></w:style>
XML
# replace the styles of the same id, then append the pleading styles
perl -0777 -i -pe '
  open my $f, "<", "$ENV{W}/styles-new.xml" or die; my $new = do { local $/; <$f> };
  my @ids = $new =~ /w:styleId="([^"]+)"/g;
  for my $id (@ids) { s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s; }
  s{<w:style [^>]*w:styleId="Table"[^>]*>.*?</w:style>}{<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="59"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="260" w:lineRule="exact"/></w:pPr><w:tblPr><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tblBorders><w:tblCellMar><w:left w:w="72" w:type="dxa"/><w:right w:w="72" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>}s;
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  s{</w:styles>}{$new</w:styles>}s;
' word/styles.xml
xmllint --noout word/styles.xml

# footer: "@FOOTER_TITLE@ - n" (PAGE field, cached 1), 12 pt, left aligned
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t xml:space="preserve">@FOOTER_TITLE@ - </w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML

# relationships and content types for the footer
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# body section: letter; one inch on all four sides; footer 0.5 in from the bottom edge
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId102"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>'
perl -0777 -i -pe 's{<w:sectPr\b.*?</w:sectPr>}{}s; s{</w:body>}{'"$SECT"'</w:body>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
