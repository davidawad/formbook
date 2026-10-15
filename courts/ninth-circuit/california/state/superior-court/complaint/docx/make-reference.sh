#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: Liberation Serif 12 point, exact 24 point
# (double) line spacing with no paragraph spacing, 0.5 inch first-line indent for body text, centered
# bold level 1-2 headings, US Letter with the CRC 2.107 margins, Word-native line numbering (28 lines
# per page are not guaranteed; see README "Engines"), a double rule on the left and a single rule on the
# right (page borders), and a footer with the page number and the document subject.
# Run once (needs pandoc, unzip, sed, zip); the result is committed. Nothing is fetched at build time.
# Usage: sh docx/make-reference.sh   (from anywhere)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"
X="$W/x"
S="$X/word/styles.xml"
DOC="$X/word/document.xml"
REL="$X/word/_rels/document.xml.rels"
CT="$X/[Content_Types].xml"

# One XML element per line, so each style can be edited by its styleId.
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\n[ \t]*/ /g' "$S" "$DOC"
sed -i -e 's#<w:style #\n<w:style #g' -e 's#</w:style>#</w:style>\n#g' "$S"

sed -i \
  -e 's#<w:rFonts [^>]*/>#<w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif" />#g' \
  -e 's#<w:sz w:val="[0-9]*" */>#<w:sz w:val="24" />#g' \
  -e 's#<w:szCs w:val="[0-9]*" */>#<w:szCs w:val="24" />#g' \
  -e 's#<w:color [^>]*/>#<w:color w:val="000000" />#g' \
  -e 's#<w:spacing w:after="200" */>#<w:spacing w:after="0" w:line="480" w:lineRule="exact" />#' \
  -e '/w:styleId="Normal"/ s#</w:style>#<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /></w:pPr></w:style>#' \
  -e '/w:styleId="BodyText"/ s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" />#' \
  -e '/w:styleId="Compact"/ s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />#' \
  -e '/w:styleId="BlockText"/ s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="exact" />#' \
  -e '/w:styleId="BlockText"/ s#w:left="480" w:right="480"#w:left="720" w:right="720"#' \
  -e '/w:styleId="Heading[1-4]"/ s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />#' \
  -e '/w:styleId="Heading[12]"/ s#<w:outlineLvl#<w:jc w:val="center" /><w:outlineLvl#' \
  -e '/w:styleId="Heading[1-4]"/ s#<w:rFonts [^>]*/>#&<w:b /><w:bCs />#' \
  -e '/w:styleId="Heading4"/ s#<w:bCs />#<w:bCs /><w:i /><w:iCs />#' \
  -e '/w:styleId="FootnoteText"/ s#</w:style>#<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:style>#' \
  "$S"

# Page: US Letter; CRC 2.107 margins (left 1.5 in, right 0.5 in); top 1 in; bottom 48 pt so that 28 lines
# of 24 pt (672 pt) fit between 72 pt and 744 pt. Footer 14.4 pt from the bottom edge.
# Page borders: double rule 18 pt left of the text, single rule 7 pt right of it (CRC 2.108).
# Line numbers 648 twips (0.45 in) left of the text, restarted each page (CRC 2.108).
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdPleadingFooter" />#' \
  -e 's#</w:footnotePr> *</w:sectPr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="720" w:bottom="960" w:left="2160" w:header="720" w:footer="288" w:gutter="0" /><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="18" w:color="auto" /><w:right w:val="single" w:sz="4" w:space="7" w:color="auto" /></w:pgBorders><w:lnNumType w:countBy="1" w:distance="648" w:restart="newPage" /></w:sectPr>#' \
  "$DOC"

# Footer part: a printed rule, the page number (12 pt), then the subject (10 pt). The Lua filter sets the
# subject from footer_title in the sample's frontmatter, so no case-specific text is in the template.
cat > "$X/word/footer1.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pBdr><w:top w:val="single" w:sz="4" w:space="1" w:color="auto" /></w:pBdr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:fldSimple w:instr=" PAGE "><w:r><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:t>1</w:t></w:r></w:fldSimple></w:p><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:fldSimple w:instr=" SUBJECT "><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr></w:r></w:fldSimple></w:p></w:ftr>
EOF
sed -i 's#</Relationships>#<Relationship Id="rIdPleadingFooter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' "$REL"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT"

rm -f "$D/reference.docx"
(cd "$X" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
