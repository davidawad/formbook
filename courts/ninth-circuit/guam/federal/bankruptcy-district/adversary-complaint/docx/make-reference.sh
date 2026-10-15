#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx, to match the typst template
# (typst/gub-adversary-complaint.typ): EB Garamond 12 pt; 24 pt exact line pitch (double spacing, 28 lines
# per page); 0.5 in first-line indent on body paragraphs; centred bold headings on one line; US Letter with
# the pleading margins (1 in top, 1.5 in left, 0.75 in right, 48 pt bottom); Word section line numbers 1 to
# 28 restarting each page; a double rule at the text's left and a single rule at its right; a centred PAGE
# field in the footer (GNLR 5.1(a)). Everything here is set in styles.xml, sectPr and the footer part; none of
# it is rendered in this sandbox (no LibreOffice), so docs/DOCX.md "Known limits" applies.
# Needs pandoc, unzip, zip, sed. Run once from anywhere: sh docx/make-reference.sh ; the result is committed.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# Parameters (lengths in twips, 20 per pt; sizes in half-points)
BODY_SZ=24            # 12 pt
FOOT_SZ=22            # 11 pt footnotes, single spaced
LINE=480              # exact 24 pt pitch (double spacing)
SINGLE=276            # exact 13.8 pt for counsel, caption and signature blocks
HEAD_BEFORE=0         # a heading occupies one numbered line
HEAD_AFTER=0
HEAD_CENTER_LEVELS=12 # Heading1 and Heading2 are centred ("#" and "##" in the markdown contract)
PG_TOP=1440
PG_BOTTOM=960         # 48 pt: 72 + 28 x 24 + 48 = 792 pt
PG_LEFT=2160          # 1.5 in
PG_RIGHT=1080         # 0.75 in
PG_FOOTER=600
LINENUM=1             # 1 = Word line numbers 1 to 28 (pleading form); 0 = none
RULES=1               # 1 = double rule left, single rule right (pleading form); 0 = none

pandoc --print-default-data-file reference.docx > "$W/ref0.docx"
unzip -q "$W/ref0.docx" -d "$W/x"
X="$W/x"

# --- styles.xml -------------------------------------------------------------------------------------------
# Flatten, then put one <w:style> per line so each edit below addresses one style by its styleId.
tr '\n' ' ' < "$X/word/styles.xml" \
  | sed -e 's#<w:style #\n<w:style #g' -e 's#</w:styles>#\n</w:styles>#' > "$W/s1.xml"
sed \
  -e 's#<w:rFonts [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#g' \
  -e "s#<w:sz w:val=\"[0-9]*\" />#<w:sz w:val=\"$BODY_SZ\" />#g" \
  -e "s#<w:szCs w:val=\"[0-9]*\" />#<w:szCs w:val=\"$BODY_SZ\" />#g" \
  -e 's#<w:color [^>]*/>#<w:color w:val="000000" />#g' \
  -e "s#<w:spacing w:\(before\|after\)=[^>]*/>#<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\" />#g" \
  -e 's#<w:i />##g' \
  "$W/s1.xml" > "$W/s2.xml"
sed \
  -e "/w:styleId=\"Heading[123]\"/ s#<w:spacing [^>]*/>#<w:spacing w:before=\"$HEAD_BEFORE\" w:after=\"$HEAD_AFTER\" w:line=\"$LINE\" w:lineRule=\"exact\" />#" \
  -e '/w:styleId="Heading[123]"/ s#<w:rFonts [^>]*/>#&<w:b />#' \
  -e "/w:styleId=\"Heading[$HEAD_CENTER_LEVELS]\"/ s#<w:outlineLvl#<w:jc w:val=\"center\" /><w:outlineLvl#" \
  -e '/w:styleId="BodyText"/ s#</w:pPr>#<w:ind w:firstLine="720" /></w:pPr>#' \
  -e '/w:styleId="FirstParagraph"/ s#</w:pPr>#<w:ind w:firstLine="720" /></w:pPr>#' \
  -e "/w:styleId=\"FootnoteText\"/ s#</w:style>#<w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\" /></w:pPr><w:rPr><w:sz w:val=\"$FOOT_SZ\" /><w:szCs w:val=\"$FOOT_SZ\" /></w:rPr></w:style>#" \
  "$W/s2.xml" > "$W/s3.xml"
# Custom paragraph styles for the cover, the caption, the signature and the lettered list (used by the filter).
cat > "$W/custom.xml" <<'EOF'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Counsel"><w:name w:val="Counsel" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="@SINGLE@" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="@LINE@" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionBlock"><w:name w:val="Caption Block" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="@SINGLE@" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature Block" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="@SINGLE@" w:lineRule="exact" /><w:ind w:left="3744" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Unnumbered"><w:name w:val="Unnumbered Paragraph" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="@LINE@" w:lineRule="exact" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered Item" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="@LINE@" w:lineRule="exact" /><w:ind w:left="1440" w:hanging="720" /></w:pPr></w:style>
EOF
sed -i -e "s#@SINGLE@#$SINGLE#g" -e "s#@LINE@#$LINE#g" "$W/custom.xml"
# Append the custom styles before the closing tag (the closing tag is the last line of s3.xml).
sed '$d' "$W/s3.xml" > "$W/s4.xml"
cat "$W/custom.xml" >> "$W/s4.xml"
echo '</w:styles>' >> "$W/s4.xml"
# Join back into one file again; the newlines were only separators between the styles.
tr -d '\n' < "$W/s4.xml" | sed -e 's#<w:style w:type#\n<w:style w:type#g' -e 's#</w:styles>#\n</w:styles>#' > "$X/word/styles.xml.tmp"
mv "$X/word/styles.xml.tmp" "$X/word/styles.xml"

# --- footer part (PAGE field, centred) --------------------------------------------------------------------
cat > "$X/word/footer1.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
EOF
sed -e 's#</Relationships>#<Relationship Id="rIdGubFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' \
  "$X/word/_rels/document.xml.rels" > "$W/rels.tmp" && mv "$W/rels.tmp" "$X/word/_rels/document.xml.rels"
sed -e 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' \
  "$X/[Content_Types].xml" > "$W/ct.tmp" && mv "$W/ct.tmp" "$X/[Content_Types].xml"

# --- document.xml: section properties ---------------------------------------------------------------------
PGBORDERS=""
if [ "$RULES" = 1 ]; then
  PGBORDERS='<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="4" w:color="auto" /><w:right w:val="single" w:sz="4" w:space="4" w:color="auto" /></w:pgBorders>'
fi
LNNUM=""
if [ "$LINENUM" = 1 ]; then
  LNNUM='<w:lnNumType w:countBy="1" w:restart="newPage" w:distance="504" />'
fi
DOC="$X/word/document.xml"
sed \
  -e 's#<w:footnotePr>#<w:footerReference w:type="default" r:id="rIdGubFooter1" /><w:footnotePr>#' \
  -e "s#</w:footnotePr>#</w:footnotePr><w:pgSz w:w=\"12240\" w:h=\"15840\" /><w:pgMar w:top=\"$PG_TOP\" w:right=\"$PG_RIGHT\" w:bottom=\"$PG_BOTTOM\" w:left=\"$PG_LEFT\" w:header=\"720\" w:footer=\"$PG_FOOTER\" w:gutter=\"0\" />$PGBORDERS$LNNUM#" \
  "$DOC" > "$W/doc.tmp" && mv "$W/doc.tmp" "$DOC"

# --- zip (inside the temp dir only) and check -------------------------------------------------------------
rm -f "$D/reference.docx"
(cd "$X" && zip -q -X -r "$W/reference.docx" .)
mv "$W/reference.docx" "$D/reference.docx"
unzip -tq "$D/reference.docx" > /dev/null
echo "$D/reference.docx"
