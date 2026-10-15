#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, to match typst/hib-motion-brief.typ:
# EB Garamond 14 pt (LBR 9004-1(b)(1): memoranda and footnotes); double spacing (line 480, auto) with
# a 0.5 in first-line indent for body text; single spacing for the counsel block, caption, block
# quotations (0.25 in inset each side), footnotes and headings. Level 1 headings are centered and bold;
# levels 2-5 are left-aligned with a hanging label (0.5 in). US Letter with 1 in margins; centered page
# number, none on page 1. Also defines the paragraph styles CounselBlock, CourtTitle, CaptionText and
# SignatureBlock that docx/hib-motion-brief.lua uses for the cover and signature.
# Not rendered here; set in styles.xml and sectPr only (no LibreOffice on the build box).
# These are set in styles.xml and sectPr; they are not rendered here (no LibreOffice on the build box).
# Run once (needs pandoc, unzip, zip, sed, tr; xmllint if present); the result is committed.
# Usage: sh docx/make-reference.sh   (any directory)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$W"
X="$W/x"
FONT="EB Garamond"
SZ=28          # half-points: 14 pt (LBR 9004-1(b)(1))
BLANK=367      # one single-spaced blank line, twips (1.31 em at 14 pt)
QUOTE=360      # block quotation inset each side, twips (0.25 in)
DOUBLE='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/>'
SINGLE='<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'

pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$X"
ST="$X/word/styles.xml"
DOC="$X/word/document.xml"

# One element per line, so the per-style edits below can address a single style.
for f in "$ST" "$DOC"; do
  tr '\n' ' ' < "$f" | sed 's#<w:style #\n<w:style #g' > "$f.tmp" && mv "$f.tmp" "$f"
done

sed -i \
  -e "s#<w:rFonts [^/]*/>#<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/>#g" \
  -e "s#<w:sz w:val=\"[0-9]*\"[^/]*/>#<w:sz w:val=\"$SZ\"/>#g" \
  -e "s#<w:szCs w:val=\"[0-9]*\"[^/]*/>#<w:szCs w:val=\"$SZ\"/>#g" \
  -e 's#<w:color [^/]*/>#<w:color w:val="000000"/>#g' \
  -e "s#<w:spacing w:after=\"200\"[^/]*/>#$DOUBLE#" \
  -e "/w:styleId=\"BodyText\"/ s#<w:spacing [^/]*/>#$DOUBLE<w:ind w:left=\"0\" w:right=\"0\" w:firstLine=\"720\"/>#" \
  -e "/w:styleId=\"Compact\"/ s#<w:spacing [^/]*/>#$DOUBLE<w:ind w:left=\"0\" w:right=\"0\" w:firstLine=\"0\"/>#" \
  -e "/w:styleId=\"BlockText\"/ s#<w:spacing [^/]*/>#<w:spacing w:before=\"$BLANK\" w:after=\"$BLANK\" w:line=\"240\" w:lineRule=\"auto\"/>#" \
  -e "/w:styleId=\"BlockText\"/ s#<w:ind [^/]*/>#<w:ind w:left=\"$QUOTE\" w:right=\"$QUOTE\" w:firstLine=\"0\"/>#" \
  -e "/w:styleId=\"FootnoteText\"/ s#</w:style>#<w:pPr>$SINGLE<w:ind w:left=\"0\" w:right=\"0\" w:firstLine=\"0\"/></w:pPr><w:rPr><w:sz w:val=\"$SZ\"/><w:szCs w:val=\"$SZ\"/></w:rPr></w:style>#" \
  "$ST"

# Headings: single spacing, bold, one blank line above and below. Level 1 centered, all caps (typst
# uses upper() for level 1). Levels 2-5: label at (level-2) x 0.5 in, text on a hanging indent of 0.5 in.
sed -i \
  -e "/w:styleId=\"Heading1\"/ s#<w:spacing [^/]*/>#<w:spacing w:before=\"$BLANK\" w:after=\"$BLANK\" w:line=\"240\" w:lineRule=\"auto\"/><w:jc w:val=\"center\"/>#" \
  -e "/w:styleId=\"Heading1\"/ s#<w:rFonts [^/]*/>#&<w:b/><w:bCs/><w:caps/>#" \
  "$ST"
for n in 2 3 4 5; do
  L=$(( (n - 1) * 720 ))
  sed -i \
    -e "/w:styleId=\"Heading$n\"/ s#<w:spacing [^/]*/>#<w:spacing w:before=\"$BLANK\" w:after=\"$BLANK\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"$L\" w:hanging=\"720\"/>#" \
    -e "/w:styleId=\"Heading$n\"/ s#<w:rFonts [^/]*/>#&<w:b/><w:bCs/>#" \
    "$ST"
done

# Custom paragraph styles for the cover, caption and signature (used by the Lua filter).
pstyle() {
  printf '<w:style w:type="paragraph" w:customStyle="1" w:styleId="%s"><w:name w:val="%s"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>%s</w:pPr><w:rPr>%s</w:rPr></w:style>' "$1" "$2" "$3" "$4"
}
CUSTOM="$(pstyle CounselBlock 'Counsel Block' "$SINGLE" '')"
CUSTOM="$CUSTOM$(pstyle CourtTitle 'Court Title' "$SINGLE<w:jc w:val=\"center\"/>" '<w:b/><w:bCs/>')"
CUSTOM="$CUSTOM$(pstyle CaptionText 'Caption Text' "$SINGLE" '')"
CUSTOM="$CUSTOM$(pstyle SignatureBlock 'Signature Block' "$SINGLE" '')"
sed -i "s#</w:styles>#$CUSTOM</w:styles>#" "$ST"

# Page size, margins, footer references (default: page number; first page: empty), and titlePg.
sed -i \
  -e 's#<w:sectPr[^>]*>#&<w:footerReference w:type="default" r:id="rIdFtr1"/><w:footerReference w:type="first" r:id="rIdFtr2"/>#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:titlePg/>#' \
  "$DOC"

NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
cat > "$X/word/footer1.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
EOF
cat > "$X/word/footer2.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p/></w:ftr>
EOF
REL='http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer'
sed -i "s#</Relationships>#<Relationship Id=\"rIdFtr1\" Type=\"$REL\" Target=\"footer1.xml\"/><Relationship Id=\"rIdFtr2\" Type=\"$REL\" Target=\"footer2.xml\"/></Relationships>#" "$X/word/_rels/document.xml.rels"
CT='application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml'
sed -i "s#</Types>#<Override PartName=\"/word/footer1.xml\" ContentType=\"$CT\"/><Override PartName=\"/word/footer2.xml\" ContentType=\"$CT\"/></Types>#" "$X/[Content_Types].xml"

if command -v xmllint > /dev/null; then
  for p in "$X/word/styles.xml" "$X/word/document.xml" "$X/word/footer1.xml" "$X/word/footer2.xml" "$X/word/_rels/document.xml.rels" "$X/[Content_Types].xml"; do
    xmllint --noout "$p"
  done
fi

(cd "$X" && zip -q -X -r "$W/reference.docx" .)
cp "$W/reference.docx" "$D/reference.docx"
echo "$D/reference.docx"
