#!/bin/sh
# Build one sample as a .docx (docs/EVAL-LOOP.md, "Engines"; tools/render-docx.sh calls this and converts the result).
#   sh docx/render.sh <court-dir> <sample.md> <out.docx>
# pandoc writes the body with ptab-patent-owner-response.lua on docx/reference.docx. The package then gets what the
# filter cannot write: the running header (the patent number is read from the frontmatter), the footers (roman for
# the contents, arabic from 1 for the body), and the body's section properties. Every XML part is checked.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
PAGE='<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'

# the patent number from the frontmatter; the running header names it (typst: "Patent Owner Response, <number>")
PN=$(yq --front-matter=extract '.patent-number' "$COURT/$SAMPLE" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
[ -n "$PN" ] || {
  echo "render.sh: $SAMPLE has no patent-number in its frontmatter" >&2
  exit 1
}

pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/ptab-patent-owner-response.lua" "$COURT/$SAMPLE" -o "$W/build.docx" || exit 1
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/build.docx")

printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
  "<w:hdr $NS><w:p><w:pPr><w:pStyle w:val=\"Header\"/></w:pPr><w:r><w:t xml:space=\"preserve\">Patent Owner Response, $PN</w:t></w:r></w:p></w:hdr>" > "$W/x/word/header-body.xml"
for f in footer-roman footer-arabic; do
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
    "<w:ftr $NS><w:p><w:pPr><w:pStyle w:val=\"Footer\"/></w:pPr><w:fldSimple w:instr=\" PAGE \"><w:r><w:t>1</w:t></w:r></w:fldSimple></w:p></w:ftr>" > "$W/x/word/$f.xml"
done

# updateFields: Word fills the contents page numbers on open (LibreOffice does not; see README, Engines). pandoc writes
# its own settings.xml; the element goes before the first later element of the schema order (CT_Settings).
perl -0pi -e 's{(<w:(?:hdrShapeDefaults|footnotePr|endnotePr|compat|docVars|rsids|mathPr|attachedSchema|themeFontLang|clrSchemeMapping|decimalSymbol|listSeparator)\b)}{<w:updateFields w:val="true"/>$1}' "$W/x/word/settings.xml"
grep -q "<w:updateFields" "$W/x/word/settings.xml" || {
  echo "render.sh: could not set updateFields in settings.xml" >&2
  exit 1
}

# relationships and content types for the three parts
perl -0pi -e 's#</Relationships>#<Relationship Id="rIdHeaderBody" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Target="header-body.xml"/><Relationship Id="rIdFooterRoman" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer-roman.xml"/><Relationship Id="rIdFooterArabic" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer-arabic.xml"/></Relationships>#' "$W/x/word/_rels/document.xml.rels"
perl -0pi -e 's#</Types>#<Override PartName="/word/header-body.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"/><Override PartName="/word/footer-roman.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer-arabic.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>#' "$W/x/[Content_Types].xml"

# the body's section (the last one, certificates included): running header, arabic numbers from 1
BODY_SECT="<w:sectPr><w:headerReference w:type=\"default\" r:id=\"rIdHeaderBody\"/><w:footerReference w:type=\"default\" r:id=\"rIdFooterArabic\"/>$PAGE<w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/></w:sectPr>"
export BODY_SECT
perl -0pi -e 'my $s = $ENV{BODY_SECT}; s{<w:sectPr(?:(?!<w:sectPr).)*?</w:sectPr>(\s*</w:body>)}{$s$1}s or s{(\s*</w:body>)}{$s$1}s' "$W/x/word/document.xml"

# integrity: every part is well-formed XML (necessary, not sufficient: see docs/DOCX.md)
for part in "$W"/x/word/*.xml "$W"/x/word/_rels/*.rels "$W/x/[Content_Types].xml"; do
  xmllint --noout "$part" || {
    echo "render.sh: ${part#$W/x/} is not well-formed XML" >&2
    exit 1
  }
done
rm -f "$OUT"
(cd "$W/x" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
unzip -tq "$OUT" > /dev/null
echo "$OUT"
