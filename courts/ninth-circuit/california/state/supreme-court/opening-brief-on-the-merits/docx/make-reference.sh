#!/bin/sh
# Builds docx/reference.docx for the California Supreme Court opening brief on the merits (rules 8.520, 8.204, 8.74).
# Starts from pandoc's default reference.docx and edits word/styles.xml, word/document.xml and the footer parts so the
# Word form matches typst/cal-opening-brief-on-the-merits.typ: TeX Gyre Schola 13 pt everywhere (footnotes included);
# body text 1.5 spaced (line 360, auto), first-line indent 0.5 in; headings single spaced, bold; US Letter with 1.5 in
# left and right margins and 1 in top and bottom; arabic page number centred in the footer, none on the cover (titlePg).
# Set in styles.xml and sectPr; not rendered here (no LibreOffice on the build box).
# Needs pandoc, unzip, zip, sed. Run once: sh docx/make-reference.sh (from any directory).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
LINE=360
AFTER=170
FONT="TeX Gyre Schola"

RFONTS="<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\" />"
COLSZ='<w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" />'
BODYP="<w:spacing w:before=\"0\" w:after=\"$AFTER\" w:line=\"$LINE\" w:lineRule=\"auto\" /><w:ind w:firstLine=\"720\" />"
HEADP='<w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" />'
SINGLE='<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" />'

pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"
S="$W/x/word/styles.xml"
DOC="$W/x/word/document.xml"
RELS="$W/x/word/_rels/document.xml.rels"
CT="$W/x/[Content_Types].xml"

# Whole-document fonts, sizes, colours and default spacing.
sed -i \
  -e "s#<w:rFonts [^>]*/>#$RFONTS#g" \
  -e 's#<w:sz w:val="[0-9]*" />#<w:sz w:val="26" />#g' \
  -e 's#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="26" />#g' \
  -e 's#<w:color w:val="[0-9A-Fa-f]*"[^/]*/>#<w:color w:val="000000" />#g' \
  -e "s#<w:spacing w:after=\"200\" />#<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"auto\" />#" \
  "$S"

# restyle ID PPR RPR: replace the paragraph and run properties of one style (pPr before rPr, as the schema requires).
restyle() {
  id=$1
  ppr=$2
  rpr=$3
  add=""
  [ -n "$ppr" ] && add="$add<w:pPr>$ppr</w:pPr>"
  [ -n "$rpr" ] && add="$add<w:rPr>$rpr</w:rPr>"
  sed -i \
    -e "/w:styleId=\"$id\"/,/<\/w:style>/{/<w:pPr>/,/<\/w:pPr>/d;/<w:rPr>/,/<\/w:rPr>/d}" \
    -e "/w:styleId=\"$id\"/,/<\/w:style>/s|</w:style>|$add</w:style>|" \
    "$S"
}

restyle Normal "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"auto\" />" "$RFONTS$COLSZ"
restyle BodyText "$BODYP" "$RFONTS$COLSZ"
restyle FirstParagraph "$BODYP" "$RFONTS$COLSZ"
restyle Compact "<w:spacing w:before=\"0\" w:after=\"120\" w:line=\"$LINE\" w:lineRule=\"auto\" />" "$RFONTS$COLSZ"
restyle BlockText '<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:right="720" />' "$RFONTS$COLSZ"
restyle Heading1 "$HEADP<w:jc w:val=\"center\" />" "$RFONTS<w:b /><w:bCs /><w:caps />$COLSZ"
restyle Heading2 "$HEADP<w:ind w:left=\"720\" w:hanging=\"720\" />" "$RFONTS<w:b /><w:bCs />$COLSZ"
restyle Heading3 "$HEADP<w:ind w:left=\"1440\" w:hanging=\"720\" />" "$RFONTS<w:b /><w:bCs />$COLSZ"
restyle Heading4 "$HEADP<w:ind w:left=\"2160\" w:hanging=\"720\" />" "$RFONTS<w:b /><w:bCs />$COLSZ"
restyle Heading5 "$HEADP<w:ind w:left=\"2880\" w:hanging=\"720\" />" "$RFONTS<w:b /><w:bCs />$COLSZ"
restyle FootnoteText "$SINGLE" "$RFONTS$COLSZ"
restyle FootnoteReference "" '<w:vertAlign w:val="superscript" />'

# Page setup: US Letter, margins 1.5 in left and right, 1 in top and bottom; footers; no number on the cover.
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrDefault" /><w:footerReference w:type="first" r:id="rIdFtrFirst" />#' \
  -e '/<w:sectPr>/,/<\/w:sectPr>/s#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="2160" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0" /><w:titlePg />#' \
  "$DOC"

NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
cat > "$W/x/word/footer1.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr>$RFONTS$COLSZ</w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr>$RFONTS$COLSZ</w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr>$RFONTS$COLSZ</w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr>$RFONTS$COLSZ</w:rPr><w:t>1</w:t></w:r><w:r><w:rPr>$RFONTS$COLSZ</w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
EOF
cat > "$W/x/word/footer2.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr $NS><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:p></w:ftr>
EOF
sed -i 's#</Relationships>#<Relationship Id="rIdFtrDefault" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /><Relationship Id="rIdFtrFirst" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer2.xml" /></Relationships>#' "$RELS"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT"

(cd "$W/x" && zip -q -X -r "$W/reference.docx" .)
cp "$W/reference.docx" "$D/reference.docx"
echo "$D/reference.docx"
