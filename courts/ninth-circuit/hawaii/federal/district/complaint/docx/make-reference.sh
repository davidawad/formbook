#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, for the D. Haw. complaint (hid).
# Mirrors typst/hid-complaint.typ: EB Garamond 14 pt (no face named for complaints, see README),
# exact 32.2 pt line pitch for the body (LR 10.2(a)(4) double spacing), first-line indent 0.5 in,
# single-spaced headings (level 1 bold capitals, level 2 hanging "I."), footnotes and counsel block,
# US Letter with 1 in margins, centered "- n -" footer.
# Set in styles.xml / sectPr / footer1.xml; NOT rendered here (no LibreOffice on the build box).
# Run once (needs pandoc, unzip, sed, zip): sh docx/make-reference.sh   (from anywhere). Output is committed.
set -eu
FONT="EB Garamond"
BODY_LINE=644        # 32.2 pt, exact
COUNSEL_SZ=22        # 11 pt counsel block (typst counsel-size)
H1_JC=left           # level 1 (complaint "# Parties"): bold capitals, left (typst render)
H1_IND=0
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$W"
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
mkdir "$W/x"
unzip -q "$W/ref0.docx" -d "$W/x"
S="$W/x/word/styles.xml"
DOC="$W/x/word/document.xml"

# styles.xml: one element per line, so each style can be edited or replaced whole.
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' -e 's#</w:style>#</w:style>\n#g' "$S"
sed -i \
  -e "s#<w:rFonts [^>]*/>#<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\" />#g" \
  -e 's#<w:sz w:val="[0-9]*" />#<w:sz w:val="28" />#g' \
  -e 's#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="28" />#g' \
  -e 's#<w:color [^>]*/>#<w:color w:val="000000" />#g' \
  -e 's#<w:spacing w:after="200" />#<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" />#' \
  "$S"
for id in BodyText FirstParagraph Compact Heading1 Heading2 Heading3 BlockText FootnoteText; do
  sed -i "/w:styleId=\"$id\"/d" "$S"
done
sed -i 's#</w:styles>##' "$S"
cat >> "$S" <<EOF
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$BODY_LINE" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$BODY_LINE" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$BODY_LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="322" w:after="322" w:line="240" w:lineRule="auto"/><w:ind w:left="$H1_IND" w:hanging="$H1_IND"/><w:jc w:val="$H1_JC"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:caps/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="322" w:after="322" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="322" w:after="322" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="140" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtCounsel"><w:name w:val="Court Counsel"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="$COUNSEL_SZ"/><w:szCs w:val="$COUNSEL_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtSingle"><w:name w:val="Court Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtCenter"><w:name w:val="Court Center"/><w:basedOn w:val="CourtSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtUnnumbered"><w:name w:val="Court Unnumbered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$BODY_LINE" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtLettered"><w:name w:val="Court Lettered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$BODY_LINE" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtSignature"><w:name w:val="Court Signature"/><w:basedOn w:val="CourtSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4680"/></w:pPr></w:style>
</w:styles>
EOF

# document.xml: footer reference first in sectPr; US Letter, 1 in margins after footnotePr (schema order).
sed -i ':a;N;$!ba;s/\n/ /g' "$DOC"
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdCourtFooter1" />#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />#' \
  "$DOC"

# footer1.xml: centered "- n -" (typst footer), PAGE field.
cat > "$W/x/word/footer1.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:t xml:space="preserve">- </w:t></w:r><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r><w:r><w:t xml:space="preserve"> -</w:t></w:r></w:p></w:ftr>
EOF
R="$W/x/word/_rels/document.xml.rels"
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdCourtFooter1" Target="footer1.xml" /></Relationships>#' "$R"
C="$W/x/[Content_Types].xml"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$C"

rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
