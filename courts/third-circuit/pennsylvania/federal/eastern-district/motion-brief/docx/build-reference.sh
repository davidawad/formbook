#!/bin/sh
# Builds docx/reference.docx for the paed motion with memorandum: pandoc's default reference.docx with the
# typography of the typst template (motion-brief/typst/paed-motion-brief.typ). Parameters, from that template:
#   EB Garamond 12 pt; 24 pt exact line pitch (double spacing); 0.5 in first-line indent for body paragraphs;
#   US Letter with 1 in margins; centered page number (arabic from 1) in the footer, none on the order and the
#   memorandum cover; single-spaced block quotations (0.5 in in from both margins), counsel blocks, caption.
#   Headings in the memorandum: I. (level 1, centered, capitals), A. (level 2, bold, hanging), 1. (level 3, bold
#   italic, hanging), numbered by Word list numbering attached to the heading styles.
# The footers and the final section's sectPr are written here; the styles are replaced by id.
# Usage: sh docx/build-reference.sh <out.docx>
# Needs pandoc and perl on PATH, and libzip's ziptool (or ZIPTOOL=/path/to/ziptool); no unzip or zip.
set -eu
OUT=$1
ZT=${ZIPTOOL:-ziptool}
FONT="EB Garamond"
SZ=24            # half-points: 12 pt
LINE=480         # twentieths of a point: 24 pt exact
MARGIN=1440      # twips: 1 in
FN_SZ=24         # footnote text, half-points (12 pt)
NUM_ID=91        # list definition for the memorandum headings

W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx

# unpack: ziptool addresses entries by index; "stat <i>" prints "name: '<name>'"
PKG=$W/pkg
mkdir -p "$PKG"
i=0
while NAME=$("$ZT" "$W/ref.docx" stat "$i" 2>/dev/null | sed -n "s/^name: '\(.*\)'\$/\1/p") && [ -n "$NAME" ]; do
  mkdir -p "$PKG/$(dirname "$NAME")"
  "$ZT" "$W/ref.docx" cat "$i" > "$PKG/$NAME"
  i=$((i + 1))
done
cd "$PKG"

# replace the style with the given id (or append it); placeholders @FONT@ @SZ@ @LINE@ @FN_SZ@ are filled in
style() {
  NEW=$(printf '%s' "$2" | sed -e "s/@FONT@/$FONT/g" -e "s/@SZ@/$SZ/g" -e "s/@LINE@/$LINE/g" -e "s/@FN_SZ@/$FN_SZ/g")
  ID=$1 NEW="$NEW" perl -0pi -e 's{<w:style [^>]*w:styleId="\Q$ENV{ID}\E"[^>]*>.*?</w:style>}{$ENV{NEW}}s or s{</w:styles>}{$ENV{NEW}</w:styles>}s' word/styles.xml
}
RPR='<w:rPr><w:rFonts w:ascii="@FONT@" w:hAnsi="@FONT@" w:eastAsia="@FONT@" w:cs="@FONT@"/><w:sz w:val="@SZ@"/><w:szCs w:val="@SZ@"/></w:rPr>'
NUMPR="<w:numPr><w:ilvl w:val=\"LVL\"/><w:numId w:val=\"$NUM_ID\"/></w:numPr>"

style Normal "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\"><w:name w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"left\"/></w:pPr>$RPR</w:style>"
style BodyText "<w:style w:type=\"paragraph\" w:styleId=\"BodyText\"><w:name w:val=\"Body Text\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"720\"/></w:pPr></w:style>"
style FirstParagraph "<w:style w:type=\"paragraph\" w:styleId=\"FirstParagraph\"><w:name w:val=\"First Paragraph\"/><w:basedOn w:val=\"BodyText\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"720\"/></w:pPr></w:style>"
style Compact "<w:style w:type=\"paragraph\" w:styleId=\"Compact\"><w:name w:val=\"Compact\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr></w:style>"
style Centered "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Centered\"><w:name w:val=\"Centered\"/><w:basedOn w:val=\"Compact\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr></w:style>"
# lettered or numbered list items: label at 0.5 in, text at 0.9 in (typst: indent 0.5 in, body-indent 0.4 in)
style Lettered "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Lettered\"><w:name w:val=\"Lettered\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:left=\"1296\" w:hanging=\"576\" w:firstLine=\"0\"/></w:pPr></w:style>"
# signature lines at the right of the order: left edge 3.7 in; the rule for the judge's line
style Signature "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Signature\"><w:name w:val=\"Signature\"/><w:basedOn w:val=\"Compact\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"5328\" w:firstLine=\"0\"/></w:pPr></w:style>"
style SigLine "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"SigLine\"><w:name w:val=\"Signature Line\"/><w:basedOn w:val=\"Signature\"/><w:qFormat/><w:pPr><w:pBdr><w:bottom w:val=\"single\" w:sz=\"4\" w:space=\"1\" w:color=\"000000\"/></w:pBdr><w:spacing w:before=\"480\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"5328\" w:right=\"720\" w:firstLine=\"0\"/></w:pPr></w:style>"
# headings: the memorandum's numbering I. / A. / 1. (numbering attached below); level 1 centered capitals
style Heading1 "<w:style w:type=\"paragraph\" w:styleId=\"Heading1\"><w:name w:val=\"heading 1\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$(printf '%s' "$NUMPR" | sed 's/LVL/0/')<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:left=\"0\" w:firstLine=\"0\"/><w:jc w:val=\"center\"/><w:outlineLvl w:val=\"0\"/></w:pPr><w:rPr><w:rFonts w:ascii=\"@FONT@\" w:hAnsi=\"@FONT@\" w:eastAsia=\"@FONT@\" w:cs=\"@FONT@\"/><w:b/><w:bCs/><w:caps/><w:color w:val=\"000000\"/><w:sz w:val=\"@SZ@\"/><w:szCs w:val=\"@SZ@\"/></w:rPr></w:style>"
style Heading2 "<w:style w:type=\"paragraph\" w:styleId=\"Heading2\"><w:name w:val=\"heading 2\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$(printf '%s' "$NUMPR" | sed 's/LVL/1/')<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:left=\"720\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"1\"/></w:pPr><w:rPr><w:rFonts w:ascii=\"@FONT@\" w:hAnsi=\"@FONT@\" w:eastAsia=\"@FONT@\" w:cs=\"@FONT@\"/><w:b/><w:bCs/><w:color w:val=\"000000\"/><w:sz w:val=\"@SZ@\"/><w:szCs w:val=\"@SZ@\"/></w:rPr></w:style>"
style Heading3 "<w:style w:type=\"paragraph\" w:styleId=\"Heading3\"><w:name w:val=\"heading 3\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$(printf '%s' "$NUMPR" | sed 's/LVL/2/')<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"@LINE@\" w:lineRule=\"exact\"/><w:ind w:left=\"720\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"2\"/></w:pPr><w:rPr><w:rFonts w:ascii=\"@FONT@\" w:hAnsi=\"@FONT@\" w:eastAsia=\"@FONT@\" w:cs=\"@FONT@\"/><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val=\"000000\"/><w:sz w:val=\"@SZ@\"/><w:szCs w:val=\"@SZ@\"/></w:rPr></w:style>"
# block quotations: single spaced, indented 0.5 in from both margins
style BlockText "<w:style w:type=\"paragraph\" w:styleId=\"BlockText\"><w:name w:val=\"Block Text\"/><w:basedOn w:val=\"BodyText\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"240\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"720\" w:right=\"720\" w:firstLine=\"0\"/></w:pPr></w:style>"
style FootnoteText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteText\"><w:name w:val=\"footnote text\"/><w:basedOn w:val=\"Normal\"/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr><w:rPr><w:rFonts w:ascii=\"@FONT@\" w:hAnsi=\"@FONT@\" w:eastAsia=\"@FONT@\" w:cs=\"@FONT@\"/><w:sz w:val=\"@FN_SZ@\"/><w:szCs w:val=\"@FN_SZ@\"/></w:rPr></w:style>"
style Footer "<w:style w:type=\"paragraph\" w:styleId=\"Footer\"><w:name w:val=\"footer\"/><w:basedOn w:val=\"Normal\"/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr>$RPR</w:style>"
style Table "<w:style w:type=\"table\" w:styleId=\"Table\"><w:name w:val=\"Table\"/><w:tblPr><w:tblBorders><w:top w:val=\"nil\"/><w:left w:val=\"nil\"/><w:bottom w:val=\"nil\"/><w:right w:val=\"nil\"/><w:insideH w:val=\"nil\"/><w:insideV w:val=\"nil\"/></w:tblBorders><w:tblCellMar><w:left w:w=\"0\" w:type=\"dxa\"/><w:right w:w=\"0\" w:type=\"dxa\"/></w:tblCellMar></w:tblPr></w:style>"

# numbering for the memorandum headings: I. (level 1), A. (level 2), 1. (level 3), a. (level 4)
ABS='<w:abstractNum w:abstractNumId="90"><w:multiLevelType w:val="multilevel"/>'
ABS="$ABS<w:lvl w:ilvl=\"0\"><w:start w:val=\"1\"/><w:numFmt w:val=\"upperRoman\"/><w:pStyle w:val=\"Heading1\"/><w:suff w:val=\"space\"/><w:lvlText w:val=\"%1.\"/><w:lvlJc w:val=\"left\"/><w:pPr><w:ind w:left=\"0\" w:firstLine=\"0\"/></w:pPr></w:lvl>"
ABS="$ABS<w:lvl w:ilvl=\"1\"><w:start w:val=\"1\"/><w:numFmt w:val=\"upperLetter\"/><w:pStyle w:val=\"Heading2\"/><w:lvlText w:val=\"%2.\"/><w:lvlJc w:val=\"left\"/><w:pPr><w:ind w:left=\"720\" w:hanging=\"720\"/></w:pPr></w:lvl>"
ABS="$ABS<w:lvl w:ilvl=\"2\"><w:start w:val=\"1\"/><w:numFmt w:val=\"decimal\"/><w:pStyle w:val=\"Heading3\"/><w:lvlText w:val=\"%3.\"/><w:lvlJc w:val=\"left\"/><w:pPr><w:ind w:left=\"720\" w:hanging=\"720\"/></w:pPr></w:lvl>"
ABS="$ABS<w:lvl w:ilvl=\"3\"><w:start w:val=\"1\"/><w:numFmt w:val=\"lowerLetter\"/><w:lvlText w:val=\"%4.\"/><w:lvlJc w:val=\"left\"/><w:pPr><w:ind w:left=\"1440\" w:hanging=\"720\"/></w:pPr></w:lvl></w:abstractNum>"
NUMDEF="<w:num w:numId=\"$NUM_ID\"><w:abstractNumId w:val=\"90\"/></w:num>"
ABS="$ABS" NUMDEF="$NUMDEF" perl -0pi -e 's{(<w:num )}{$ENV{ABS}$1}s or s{</w:numbering>}{$ENV{ABS}</w:numbering>}s; s{</w:numbering>}{$ENV{NUMDEF}</w:numbering>}s' word/numbering.xml

# footers: footer1 = centered PAGE field (cached 1); footer2 = empty (order and memorandum cover have no number)
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > word/footer2.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml"/><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr2" Target="footer2.xml"/></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' '[Content_Types].xml'

# settings: Word updates the TOC field on open
perl -0pi -e 's{(<w:settings [^>]*>)}{$1<w:updateFields w:val="true"/>}s' word/settings.xml

# body: no content (pandoc replaces it); the final section (the memorandum body) is US Letter, 1 in margins,
# arabic page numbers from 1, with the page-number footer
M=$MARGIN perl -0pi -e 's{<w:body>.*</w:body>}{<w:body><w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="$ENV{M}" w:right="$ENV{M}" w:bottom="$ENV{M}" w:left="$ENV{M}" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr></w:body>}s' word/document.xml

for part in $(find . -name '*.xml' -o -name '*.rels' | sed 's|^\./||'); do xmllint --noout "$part"; done

case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
set -f
set --
for f in $(find . -type f | sed 's|^\./||' | LC_ALL=C sort); do set -- "$@" add_file "$f" "$f" 0 0; done
"$ZT" -n "$OUT" "$@"
echo "$OUT"
