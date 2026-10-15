#!/bin/sh
# Builds docx/reference.docx for okwd motions and briefs from pandoc's default reference, so the Word styles and the page
# setup match typst/okwd-motion-brief.typ: EB Garamond 13 pt, exact 26 pt (double) line pitch, 17.55 pt after each
# paragraph (the typst body-leading gap), 0.5 in first-line indent, single 15 pt blocks for the caption and the
# signature, centered bold capitals for level-1 headings, bold left level-2 and bold italic left level-3 headings, letter page with 1 in margins, centered page number.
# Usage: sh docx/build-reference.sh [out.docx]     (default: docx/reference.docx; needs pandoc and ziptool on PATH)
# ziptool (libzip) stands in for unzip/zip, which this box lacks. xmllint checks each XML part.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/base.docx" --print-default-data-file reference.docx
cp "$W/base.docx" "$OUT"
# the part index of a zip entry (ziptool prints "name ... found at index N")
idx() { ziptool "$OUT" name_locate "$1" 0 | awk '{print $NF}'; }

cat > "$W/styles.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults>
<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/></w:pPr></w:pPrDefault>
</w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont"><w:name w:val="Default Paragraph Font"/><w:uiPriority w:val="1"/><w:semiHidden/><w:unhideWhenUsed/></w:style>
<w:style w:type="table" w:default="1" w:styleId="TableNormal"><w:name w:val="Normal Table"/><w:uiPriority w:val="99"/><w:semiHidden/><w:unhideWhenUsed/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="351" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="BodyKeep"><w:name w:val="Body Keep With Next"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="351" w:after="351" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="351" w:after="351" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="351" w:after="351" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBody"><w:name w:val="Centered Body"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleIndent"><w:name w:val="Single Indent"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleKeep"><w:name w:val="Single Keep With Next"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="351" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:left="1152" w:hanging="432" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:rPr><w:color w:val="000000"/><w:u w:val="single"/></w:rPr></w:style>
</w:styles>
XML
ziptool "$OUT" replace_file_contents "$(idx word/styles.xml)" "$(cat "$W/styles.xml")"

# footer: the page number, centered (typst: footer = centered page counter at type size)
cat > "$W/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
ziptool "$OUT" add word/footer1.xml "$(cat "$W/footer1.xml")"

# relationships and content types for the footer part
ziptool "$OUT" cat "$(idx word/_rels/document.xml.rels)" > "$W/rels.xml"
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>|' "$W/rels.xml"
ziptool "$OUT" replace_file_contents "$(idx word/_rels/document.xml.rels)" "$(cat "$W/rels.xml")"
ziptool "$OUT" cat "$(idx '[Content_Types].xml')" > "$W/ct.xml"
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' "$W/ct.xml"
ziptool "$OUT" replace_file_contents "$(idx '[Content_Types].xml')" "$(cat "$W/ct.xml")"

# section: letter, 1 in margins, footer at 0.5 in, the page-number footer (replaces the default sectPr)
ziptool "$OUT" cat "$(idx word/document.xml)" > "$W/document.xml"
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
awk -v sect="$SECT" '/<w:sectPr>/ {print sect; skip = 1} skip && /<\/w:sectPr>/ {skip = 0; next} !skip {print}' "$W/document.xml" > "$W/document.new" && mv "$W/document.new" "$W/document.xml"
grep -q 'rId100' "$W/document.xml" || { echo "build-reference.sh: section not replaced" >&2; exit 1; }
ziptool "$OUT" replace_file_contents "$(idx word/document.xml)" "$(cat "$W/document.xml")"

# every XML part of the reference must be well formed
for n in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  ziptool "$OUT" cat "$(idx "$n")" > "$W/check.xml"
  xmllint --noout "$W/check.xml"
done
echo "$OUT"
