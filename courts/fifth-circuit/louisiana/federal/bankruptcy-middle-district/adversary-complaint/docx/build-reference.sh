#!/bin/sh
# Builds docx/reference.docx for lamb (U.S. Bankruptcy Court, M.D. La.) from pandoc's default reference.
# Mandated form (LR 5005-2, 2022 Local Rules): 8.5 x 11 in (LR 5005-2(a)); 12-point font and double
# spacing (LR 5005-2(b)); the font is EB Garamond, as in typst/ (vendored, OFL). Margins 1 in (style
# choice, as in typst/). Single spacing for the caption, footnotes, block quotations and
# signature (typst/ uses the same). Page number centred in the footer (PAGE field).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, xmllint, unzip, zip on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q ../ref.docx
xmllint --format --output word/styles.xml word/styles.xml
xmllint --format --output word/document.xml word/document.xml

NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
DROP="Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 Title FootnoteText BlockText Footer Centered CenteredGap TitleLine NoticeHead Single CaptionRight CaptionV CaptionBreak CaptionCell SignatureGap Lettered"

cat > "$W/defaults.xml" <<XML
  <w:docDefaults>
    <w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:pPrDefault>
  </w:docDefaults>
XML

# new style definitions. Double = exact 24 pt (480 twips) on the 12-point face; single = auto 240.
cat > "$W/styles-new.xml" <<XML
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="168" w:after="168" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="168" w:after="168" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="168" w:after="168" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="168" w:after="168" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredGap"><w:name w:val="Centered Gap"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="360" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="NoticeHead"><w:name w:val="Notice Head"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="168" w:after="168" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="TitleLine"><w:name w:val="Title Line"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="504" w:after="168" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRight"><w:name w:val="Caption Right"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="2160" w:firstLine="0"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionV"><w:name w:val="Caption V"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="108" w:after="108" w:line="240" w:lineRule="auto"/><w:ind w:left="1080" w:firstLine="0"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionBreak"><w:name w:val="Caption Break"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="216" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCell"><w:name w:val="Caption Cell"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="144" w:firstLine="0"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureGap"><w:name w:val="Signature Gap"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="168" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
XML

# replace docDefaults; drop the listed styles; append the new ones before </w:styles>
awk -v drop="$DROP" -v defs="$W/defaults.xml" -v news="$W/styles-new.xml" '
BEGIN { n = split(drop, a, " "); for (i = 1; i <= n; i++) gone["\"" a[i] "\""] = 1 }
/<w:docDefaults>/ { while ((getline l < defs) > 0) print l; skip = 1 }
skip { if ($0 ~ /<\/w:docDefaults>/) skip = 0; next }
/<w:style / {
  id = ""
  if (match($0, /w:styleId="[^"]*"/)) id = substr($0, RSTART + 11, RLENGTH - 12)
  if (gone["\"" id "\""]) { drop_style = 1 }
}
drop_style { if ($0 ~ /<\/w:style>/) drop_style = 0; next }
/<\/w:styles>/ { while ((getline l < news) > 0) print l }
{ print }
' word/styles.xml > "$W/styles.out" && mv "$W/styles.out" word/styles.xml

# body section: letter, 1 in margins, centred page-number footer (replaces the pandoc sectPr)
cat > "$W/sect.xml" <<XML
    <w:sectPr>
      <w:footerReference w:type="default" r:id="rId100"/>
      <w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
    </w:sectPr>
XML
awk -v sect="$W/sect.xml" '
/<w:sectPr>/ { while ((getline l < sect) > 0) print l; skip = 1 }
skip { if ($0 ~ /<\/w:sectPr>/) skip = 0; next }
{ print }
' word/document.xml > "$W/doc.out" && mv "$W/doc.out" word/document.xml

cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
cd "$W/pkg"
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
