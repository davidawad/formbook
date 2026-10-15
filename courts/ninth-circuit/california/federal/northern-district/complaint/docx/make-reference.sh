#!/bin/sh
# Builds docx/reference.docx for the N.D. Cal. complaint, from pandoc's default reference.docx.
# Matches typst/cand-complaint.typ where Word can carry it (set in styles.xml, document.xml and the footer part; not rendered here):
#   font        Liberation Serif 12 pt (metric-compatible Times New Roman, docs/FONTS.md), black
#   spacing     exact 24 pt lines everywhere (double spacing, 28 lines per page), no space before or after
#   footnotes   12 pt, single spaced (Civil L.R. 3-4(c)(2) exempts footnotes from double spacing)
#   page        US Letter; top 1 in, bottom 0.67 in (28 x 24 pt = 672 pt fills the text area), left 1.5 in, right 0.75 in
#   pleading    line numbers 1-28 restarting each page (w:lnNumType; cover and signature styles are unnumbered); double rule left, single rule right (w:pgBorders)
#   footer      PAGE field, 10 pt, centred. The paper title and case number are case text: not in the reference.
# Needs pandoc, unzip, sed, zip. Run once from the doc-type folder: sh docx/make-reference.sh ; the result is committed.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"
S="$W/x/word/styles.xml"
DOC="$W/x/word/document.xml"
REL="$W/x/word/_rels/document.xml.rels"
CT="$W/x/[Content_Types].xml"

cat > "$W/styles.sed" <<'SED'
# 1. theme fonts go (single-line and wrapped); the court font is set once in docDefaults
/<w:rFonts[^>]*\/>/d
/<w:rFonts[^>]*$/,/\/>/d
# 2. docDefaults: Liberation Serif, 12 pt
/<w:rPrDefault>/,/<\/w:rPrDefault>/ s#<w:sz w:val="[0-9]*" />#<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif" /><w:sz w:val="24" />#
s#<w:sz w:val="[0-9]*" />#<w:sz w:val="24" />#
s#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="24" />#
# 3. black text; theme colours go (single-line and wrapped)
s#<w:color [^>]*/>#<w:color w:val="000000" />#
/<w:color [^>]*$/,/\/>/c\
<w:color w:val="000000" />
# 4. exact 24 pt lines, no space before or after (double spacing on the 24 pt grid)
s#<w:spacing w:before="[0-9]*" w:after="[0-9]*" />#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />#
s#<w:spacing w:after="[0-9]*" />#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />#
# 5. body text: first-line indent 0.5 in; list text is not indented by the body style
/w:styleId="BodyText"/,/<\/w:style>/ s#<w:spacing [^>]*/>#& <w:ind w:firstLine="720" />#
/w:styleId="Compact"/,/<\/w:style>/ s#<w:spacing [^>]*/>#& <w:ind w:firstLine="0" />#
# 6. headings: levels 1 and 2 centred and bold; level 3 bold italic at the margin
/w:styleId="Heading[12]"/,/<\/w:style>/ s#<w:spacing [^>]*/>#& <w:jc w:val="center" />#
/w:styleId="Heading[123]"/,/<\/w:style>/ s#<w:rPr>#<w:rPr><w:b /><w:bCs />#
/w:styleId="Heading3"/,/<\/w:style>/ s#<w:b /><w:bCs />#<w:b /><w:bCs /><w:i /><w:iCs />#
# 7. footnotes: single spaced, 6 pt after
/w:styleId="FootnoteText"/,/<\/w:style>/ s#</w:style>#<w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" /></w:pPr></w:style>#
# 8. paragraph styles the Lua filter uses (cover, caption, signature); single spaced
s#</w:styles>#<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleSpaced"><w:name w:val="Single Spaced" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:suppressLineNumbers /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleCenteredBold"><w:name w:val="Single Centered Bold" /><w:basedOn w:val="SingleSpaced" /><w:qFormat /><w:pPr><w:suppressLineNumbers /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation" /><w:basedOn w:val="SingleSpaced" /><w:qFormat /><w:pPr><w:suppressLineNumbers /><w:ind w:left="2880" w:firstLine="0" /></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block" /><w:basedOn w:val="SingleSpaced" /><w:qFormat /><w:pPr><w:suppressLineNumbers /><w:ind w:left="4320" w:firstLine="0" /></w:pPr></w:style></w:styles>#
SED
sed -f "$W/styles.sed" "$S" > "$S.tmp" && mv "$S.tmp" "$S"

# page: US Letter, margins as above; the sectPr names the footer first (schema order)
cat > "$W/doc.sed" <<'SED'
s#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdCandFtr1" />#
s#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="360" w:gutter="0" /><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="4" w:color="auto" /><w:right w:val="single" w:sz="4" w:space="4" w:color="auto" /></w:pgBorders><w:lnNumType w:countBy="1" w:distance="432" w:restart="newPage" />#
SED
sed -f "$W/doc.sed" "$DOC" > "$DOC.tmp" && mv "$DOC.tmp" "$DOC"

cat > "$W/x/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
sed 's#</Relationships>#<Relationship Id="rIdCandFtr1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' "$REL" > "$REL.tmp" && mv "$REL.tmp" "$REL"
sed 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT" > "$CT.tmp" && mv "$CT.tmp" "$CT"

rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
