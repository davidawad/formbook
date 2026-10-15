#!/bin/sh
# Builds docx/reference.docx for the pamb (U.S. Bankruptcy Court, M.D. Pa.) brief types from pandoc's default
# reference.docx, to match typst/pamb-*.typ: EB Garamond 13 pt, exact 24 pt (double) line spacing, 0.5 in
# first-line indent, US Letter with 1 in margins, centered PAGE footer, headings (bold, caps level 1), footnotes
# 13 pt single spaced, a 1 pt grid for tables, and the cover and signature paragraph styles used by pamb.lua.
# Usage: sh docx/build-reference.sh <out.docx> <footer-pt> <heading-align: center|left>
#   adversary-complaint: 11 center      motion-brief: 13 left
# Needs pandoc, perl, xmllint and ziptool (libzip) on PATH. unzip and zip are not used (ziptool reads and writes the
# archive); perl does the in-place XML edits, as in the eighth-circuit script.
set -eu
OUT=$1
FOOTER_PT=$2
HEADING=$3
FONT="EB Garamond"
BODY=26          # 13 pt, half-points
LINE=480         # 24 pt exact, twips
FOOT_HALF=$((FOOTER_PT * 2))
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
P="$W/pkg"
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
# extract every part (ziptool addresses entries by index)
N=$(ziptool "$W/ref.docx" get_num_entries 0 | awk '{print $1}')
mkdir -p "$P"
i=0
while [ "$i" -lt "$N" ]; do
  name=$(ziptool "$W/ref.docx" stat "$i" | sed -n "s/^name: '\(.*\)'\$/\1/p")
  mkdir -p "$P/$(dirname "$name")"
  ziptool "$W/ref.docx" cat "$i" > "$P/$name"
  i=$((i + 1))
done
cd "$P"

# heading geometry: centered level 1 (adversary) or a numbered hanging label (motion, 0.5 in per level)
if [ "$HEADING" = center ]; then
  H1_IND='<w:ind w:left="0" w:firstLine="0"/>'; H1_JC='<w:jc w:val="center"/>'
  H2_IND='<w:ind w:left="0" w:firstLine="0"/>'; H2_JC=''
  H3_IND='<w:ind w:left="0" w:firstLine="0"/>'; H3_JC=''
  H4_IND='<w:ind w:left="0" w:firstLine="0"/>'; H4_JC=''
else
  H1_IND='<w:ind w:left="720" w:firstLine="-720"/>'; H1_JC=''
  H2_IND='<w:ind w:left="1440" w:firstLine="-720"/>'; H2_JC=''
  H3_IND='<w:ind w:left="2160" w:firstLine="-720"/>'; H3_JC=''
  H4_IND='<w:ind w:left="2880" w:firstLine="-720"/>'; H4_JC=''
fi

# 1. replace the styles the builder uses (drop, then add the new definitions)
drop_style() {
  perl -0777 -pi -e 's{<w:style [^>]*w:styleId="'"$1"'"[^>]*>.*?</w:style>}{}s' word/styles.xml
}
for id in Normal BodyText Compact BlockText FootnoteText Table Heading1 Heading2 Heading3 Heading4; do
  drop_style "$id"
done
cat > "$W/docdefaults.xml" <<XML
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="$FONT" w:hAnsi="$FONT" w:eastAsia="$FONT" w:cs="$FONT"/><w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>
XML
perl -0777 -pi -e 'BEGIN{ local $/; open my $f, "<", "'"$W"'/docdefaults.xml" or die; $n = <$f>; } s{<w:docDefaults>.*?</w:docDefaults>}{$n}s' word/styles.xml

cat > "$W/new-styles.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="234" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="234" w:line="$LINE" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/></w:rPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:tblPr><w:tblBorders><w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:left w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:insideH w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:insideV w:val="single" w:sz="8" w:space="0" w:color="000000"/></w:tblBorders><w:tblCellMar><w:left w:w="100" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/>$H1_IND$H1_JC<w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/>$H2_IND$H2_JC<w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/>$H3_IND$H3_JC<w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/>$H4_IND$H4_JC<w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitlePage"><w:name w:val="Court Title Page"/><w:basedOn w:val="CourtTitle"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionTitle"><w:name w:val="Caption Title"/><w:basedOn w:val="CourtTitle"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBold"><w:name w:val="Centered Bold"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBoldPage"><w:name w:val="Centered Bold Page"/><w:basedOn w:val="CenteredBold"/><w:qFormat/><w:pPr><w:pageBreakBefore/><w:spacing w:before="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Prayer"><w:name w:val="Prayer"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:left="1080" w:firstLine="-360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ServedLine"><w:name w:val="Served Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ServedLast"><w:name w:val="Served Last"/><w:basedOn w:val="ServedLine"/><w:qFormat/><w:pPr><w:keepNext w:val="0"/><w:spacing w:after="240"/></w:pPr></w:style>
XML
perl -0777 -pi -e 'BEGIN{ local $/; open my $f, "<", "'"$W"'/new-styles.xml" or die; $n = <$f>; } s{</w:styles>}{$n</w:styles>}' word/styles.xml

# footnote reference and other pandoc styles keep their definitions; the footer is a PAGE field
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="$FOOT_HALF"/><w:szCs w:val="$FOOT_HALF"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="$FOOT_HALF"/><w:szCs w:val="$FOOT_HALF"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="$FOOT_HALF"/><w:szCs w:val="$FOOT_HALF"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="$FOOT_HALF"/><w:szCs w:val="$FOOT_HALF"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="$FOOT_HALF"/><w:szCs w:val="$FOOT_HALF"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0777 -pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# body section: US Letter, 1 in margins, the footer (replaces pandoc's sectPr, which has no page setup)
perl -0777 -pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$part"
done

# pack: [Content_Types].xml first, then the rest
rm -f "$OUT"
set --
for f in '[Content_Types].xml' $(find _rels docProps word -type f | sort); do
  set -- "$@" add_file "$f" "$f" 0 "$(wc -c < "$f" | tr -d ' ')"
done
ziptool -n -t "$OUT" "$@"
echo "$OUT"
