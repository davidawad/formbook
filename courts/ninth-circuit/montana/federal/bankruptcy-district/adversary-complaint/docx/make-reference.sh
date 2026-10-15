#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx so that the styles, the page setup
# and the footer match the typst template (typst/mtb-adversary-complaint.typ, the tier-1 form of
# Mont. LBR 5005-2 and Fed. R. Bankr. P. 9004):
#   EB Garamond 13 pt; body lines exact 24 pt (double); first-line indent 0.5 in; no space between
#   paragraphs; headings centered, bold, capitals; block quotes and footnotes single-spaced;
#   US Letter, 1 in margins; centered PAGE field in the footer.
# Set in styles.xml, sectPr and footer1.xml. Not rendered here (no LibreOffice on the build box).
# Run once; the result is committed. Needs pandoc, unzip, zip, sed, awk.
# Usage: sh docx/make-reference.sh   (any working directory; writes docx/reference.docx beside this script)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT="$D/reference.docx"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
# Every OOXML part is written and zipped inside $W only.
cd "$W"
pandoc -o ref0.docx --print-default-data-file reference.docx
unzip -q ref0.docx -d x
S="$W/x/word/styles.xml"

# 1. docDefaults: EB Garamond 13 pt, single spacing, no space after.
sed -i \
  -e '/<w:docDefaults>/,/<\/w:docDefaults>/ s#<w:rFonts [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#' \
  -e '/<w:docDefaults>/,/<\/w:docDefaults>/ s#<w:sz w:val="[0-9]*" />#<w:sz w:val="26" />#' \
  -e '/<w:docDefaults>/,/<\/w:docDefaults>/ s#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="26" />#' \
  -e '/<w:docDefaults>/,/<\/w:docDefaults>/ s#<w:spacing w:after="200" />#<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" />#' \
  "$S"

# 2. Replace the paragraph and heading styles pandoc uses for the body, with the court's rules.
cat > "$W/new-styles.xml" <<'EOF'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="480" w:lineRule="exact" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Heading1" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:outlineLvl w:val="1" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Heading1" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:outlineLvl w:val="2" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="99" /><w:unhideWhenUsed /><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
EOF
awk -v NEW="$W/new-styles.xml" '
  BEGIN {
    n = split("Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 BlockText FootnoteText", a, " ")
    for (i = 1; i <= n; i++) want[a[i]] = 1
  }
  /<w:style / {
    skip = 0
    if (match($0, /w:styleId="[^"]*"/)) {
      id = substr($0, RSTART + 11, RLENGTH - 12)
      if (id in want) skip = 1
    }
  }
  skip { if ($0 ~ /<\/w:style>/) skip = 0; next }
  /<\/w:styles>/ {
    while ((getline line < NEW) > 0) print line
    close(NEW)
  }
  { print }
' "$S" > "$W/styles.new" && mv "$W/styles.new" "$S"

# 3. Footer: centered PAGE field (new part, relationship and content type).
mkdir -p "$W/x/word/_rels"
cat > "$W/x/word/footer1.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
EOF
R="$W/x/word/_rels/document.xml.rels"
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdMtbFtr1" Target="footer1.xml" /></Relationships>#' "$R"
CT="$W/x/[Content_Types].xml"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT"

# 4. Section: footer reference, US Letter, 1 in margins (order per CT_SectPr: footerReference, footnotePr, pgSz, pgMar).
DOC="$W/x/word/document.xml"
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdMtbFtr1" />#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />#' \
  "$DOC"

# 5. Zip from inside the temp tree to the absolute output path.
rm -f "$OUT"
(cd "$W/x" && zip -q -X -r "$OUT" .)
echo "$OUT"
