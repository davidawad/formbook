#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (gud, GNLR 5.1, 2022).
# Set in styles.xml and document.xml, not rendered here (no LibreOffice on the build box):
#   EB Garamond 12 pt everywhere (the vendored face; GNLR names none); black text;
#   double spacing as an exact 24 pt line pitch (GNLR 5.1(a)); 12 pt paragraph gap after (16.2 pt, as typst);
#   body paragraphs with a 0.5 in first-line indent; headings bold, level 1 centred, 24 pt above;
#   footnotes single spaced; US Letter with 1 in margins; centred PAGE number in the footer (GNLR 5.1(a)).
# Custom styles GudSingle (single spacing, counsel, caption, signature) and GudList (lettered items) are
# used by gud.lua. Needs pandoc, unzip, zip, sed, awk (xmllint optional). Run once; the result is committed.
# Usage: sh docx/make-reference.sh   (from anywhere; all OOXML work happens in a fresh temp directory)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$W"

pandoc -o ref0.docx --print-default-data-file reference.docx
unzip -q ref0.docx -d x
S=x/word/styles.xml
DOC=x/word/document.xml
RELS=x/word/_rels/document.xml.rels
CT='x/[Content_Types].xml'

# 1. Fonts, colour, size and spacing for every style (multi-line elements are joined first by sed -z).
sed -z -i \
  -e 's#<w:rFonts[^>]*>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#g' \
  -e 's#<w:color [^>]*>#<w:color w:val="000000" />#g' \
  -e 's#<w:sz w:val="[0-9]*" />#<w:sz w:val="24" />#g' \
  -e 's#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="24" />#g' \
  -e 's#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="324" w:line="480" w:lineRule="exact" />#g' \
  "$S"

# 2. Per-style pieces: headings (bold, level 1 centred, 24 pt above), first-line indent for body text,
#    no indent for lists, single-spaced footnotes, and the two custom styles.
awk '
/<w:style / {
  id = ""
  if (match($0, /w:styleId="[^"]*"/)) id = substr($0, RSTART + 11, RLENGTH - 12)
}
/<\/w:styles>/ {
  print "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"GudSingle\"><w:name w:val=\"GudSingle\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"276\" w:lineRule=\"exact\" /></w:pPr></w:style>"
  print "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"GudList\"><w:name w:val=\"GudList\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr><w:spacing w:before=\"0\" w:after=\"324\" w:line=\"480\" w:lineRule=\"exact\" /><w:ind w:left=\"1296\" w:hanging=\"576\" /></w:pPr></w:style>"
  print
  next
}
id ~ /^Heading[123]$/ {
  if ($0 ~ /<w:spacing /) sub(/w:before="0"/, "w:before=\"480\"")
  if ($0 ~ /<w:color /) print "<w:b />"
  if (id == "Heading1" && $0 ~ /<w:outlineLvl /) print "<w:jc w:val=\"center\" />"
}
id == "BodyText" && $0 ~ /<w:spacing / {
  print
  print "<w:ind w:firstLine=\"720\" />"
  next
}
id == "Compact" && $0 ~ /<w:spacing / {
  print
  print "<w:ind w:left=\"0\" w:firstLine=\"0\" />"
  next
}
id == "FootnoteText" && $0 ~ /<\/w:style>/ {
  print "<w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\" /></w:pPr>"
  print
  next
}
{ print }
' "$S" > "$W/styles.new"
mv "$W/styles.new" "$S"

# 3. Page: US Letter, 1 in margins, footer reference (footerReference must precede footnotePr in sectPr).
sed -z -i 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdGudFooter1" />#' "$DOC"
sed -i 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />#' "$DOC"

# 4. Footer part: centred PAGE field, 12 pt (GNLR 5.1(a): pages numbered consecutively at the bottom).
cat > x/word/footer1.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
EOF
sed -i 's#</Relationships>#<Relationship Id="rIdGudFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' "$RELS"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT"

if command -v xmllint > /dev/null; then
  for p in "$S" "$DOC" "$RELS" "$CT" x/word/footer1.xml; do xmllint --noout "$p"; done
fi

rm -f "$D/reference.docx"
(cd x && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
