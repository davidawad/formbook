#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for idd (D. Idaho Loc. Civ. R. 5.2), the same form as the
# typst template: EB Garamond 12 point everywhere (footer included); body and headings at exact 24 point (double
# spacing); counsel, caption, signature and footnotes single-spaced; US Letter with 1 inch margins; a page number in
# the footer. Set in styles.xml, document.xml (sectPr) and footer1.xml; not rendered here (see README.md, Engines).
# Run once (needs pandoc, unzip, zip, sed); the result is committed. Everything is unpacked in a fresh temp dir.
# Usage: sh docx/make-reference.sh   (from anywhere)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$W"
pandoc -o ref0.docx --print-default-data-file reference.docx
unzip -q ref0.docx -d x
cd "$W/x"

# One XML tag per line, so each element is matched by line-based sed and each style block is a line range.
for f in word/styles.xml word/document.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  tr '\n' ' ' < "$f" | sed 's#>[[:space:]]*<#>\n<#g; s#[[:space:]]*$##' > "$f.tmp"
  mv "$f.tmp" "$f"
done

S=word/styles.xml
# 1. Every font, colour and size already in pandoc's styles becomes the court's (theme fonts and blue headings go).
sed -i \
  -e 's#<w:rFonts [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#g' \
  -e 's#<w:color [^>]*/>#<w:color w:val="000000" />#g' \
  -e 's#<w:sz w:val="[0-9]*"[^>]*/>#<w:sz w:val="24" />#g' \
  -e 's#<w:szCs w:val="[0-9]*"[^>]*/>#<w:szCs w:val="24" />#g' \
  "$S"

# 2. Document defaults, in place (docDefaults must stay before the style definitions).
cat > "$W/docdefaults.xml" <<'EOF'
<w:docDefaults>
<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault>
<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault>
</w:docDefaults>
EOF
grep -q '<w:docDefaults>' "$S" || { echo "make-reference.sh: no docDefaults in pandoc styles" >&2; exit 1; }
sed -i -e '/<w:docDefaults>/,/<\/w:docDefaults>/{/<w:docDefaults>/r '"$W/docdefaults.xml" -e 'd}' "$S"

# 3. Styles this template sets itself: drop pandoc's version, append ours below.
for id in Normal BodyText Compact Heading1 Heading2 Heading3 FootnoteText BlockText; do
  sed -i "/<w:style [^>]*w:styleId=\"$id\">/,/<\/w:style>/d" "$S"
done
grep -q '^</w:styles>$' "$S" || { echo "make-reference.sh: unexpected end of styles.xml" >&2; exit 1; }
sed -i '$d' "$S"
cat >> "$S" <<'EOF'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:caps /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:jc w:val="center" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:b /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:jc w:val="left" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr><w:b /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text" /><w:basedOn w:val="Normal" /><w:next w:val="FootnoteText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:right="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleSpaced"><w:name w:val="Single Spaced" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title" /><w:basedOn w:val="SingleSpaced" /><w:qFormat /><w:pPr><w:jc w:val="center" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block" /><w:basedOn w:val="SingleSpaced" /><w:qFormat /><w:pPr><w:ind w:left="4464" /></w:pPr></w:style>
</w:styles>
EOF

# 4. Page: US Letter, 1 inch margins, footer 0.4 inch from the bottom edge (typst footer-descent). The footer part
#    carries the page number only: the case title in the typst footer is case-specific, so it is not in a template.
DOC=word/document.xml
grep -q '<w:sectPr>' "$DOC" && grep -q '</w:footnotePr>' "$DOC" || { echo "make-reference.sh: unexpected sectPr" >&2; exit 1; }
grep -q 'xmlns:r=' "$DOC" || { echo "make-reference.sh: document.xml has no r namespace" >&2; exit 1; }
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdIddFooter1" />#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="576" w:gutter="0" /><w:cols w:space="720" /><w:docGrid w:linePitch="360" />#' \
  "$DOC"
cat > word/footer1.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="left" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
EOF
sed -i 's#</Relationships>#<Relationship Id="rIdIddFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' word/_rels/document.xml.rels
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' '[Content_Types].xml'

# 5. Pack. The output path is absolute; nothing is written into the working tree.
rm -f "$D/reference.docx"
zip -q -X -r "$D/reference.docx" .
echo "$D/reference.docx"
