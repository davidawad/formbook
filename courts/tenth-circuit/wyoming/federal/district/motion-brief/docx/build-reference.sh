#!/bin/sh
# Builds docx/reference.docx for D. Wyo. filings (wyd) from pandoc's default reference.docx.
# Mandated form (D. Wyo. LR 10.1(a), see ../README.md): letter paper, 1 in margins, typed and double spaced,
# not less than 12 pt. Set here: EB Garamond 13 pt (the typst template's face and size; the rule names no face),
# exact 26 pt line pitch (the typst template's double spacing at 13 pt), first-line indent 0.5 in, page number
# centered in the footer.
# Usage: sh docx/build-reference.sh <out.docx>
# Needs pandoc, xmllint and ziptool (libzip, on PATH; this box has no unzip or zip).
set -eu
OUT=$1
FONT="EB Garamond"
SZ=26          # half-points: 13 pt
LINE=520       # twips, exact: 26 pt
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
PKG="$W/pkg"
mkdir -p "$PKG"

# ---- unpack pandoc's default reference with ziptool (entry names from stat, contents from cat) ----
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
N=$(ziptool "$W/ref.docx" get_num_entries 0 | awk '{print $1}')
i=0
while [ "$i" -lt "$N" ]; do
  nm=$(ziptool "$W/ref.docx" stat "$i" | sed -n "s/^name: '\(.*\)'$/\1/p")
  mkdir -p "$PKG/$(dirname "$nm")"
  ziptool "$W/ref.docx" cat "$i" > "$PKG/$nm"
  i=$((i + 1))
done

ST="$PKG/word/styles.xml"
FONTS="<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/>"
RPR="<w:rPr>$FONTS<w:sz w:val=\"$SZ\"/><w:szCs w:val=\"$SZ\"/></w:rPr>"

# ---- document defaults: the face and size everywhere; no default spacing after ----
perl -0pi -e "s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$FONTS<w:sz w:val=\"$SZ\"/><w:szCs w:val=\"$SZ\"/><w:lang w:val=\"en-US\" w:eastAsia=\"en-US\" w:bidi=\"ar-SA\"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/></w:pPr></w:pPrDefault></w:docDefaults>}s" "$ST"

# ---- replace the built-in styles this brief uses (whole <w:style> blocks, so no theme colour or size survives) ----
replace_style() { # id, full <w:style> xml
  perl -0pi -e "s{<w:style [^>]*w:styleId=\"$1\".*?</w:style>}{$2}s" "$ST"
}
add_style() { # full <w:style> xml, appended before the closing tag
  perl -0pi -e "s{</w:styles>}{$1</w:styles>}" "$ST"
}
body="<w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"720\"/><w:jc w:val=\"left\"/></w:pPr>"
replace_style Normal "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\"><w:name w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr>$RPR</w:style>"
replace_style BodyText "<w:style w:type=\"paragraph\" w:styleId=\"BodyText\"><w:name w:val=\"Body Text\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/>$body$RPR</w:style>"
replace_style FirstParagraph "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"FirstParagraph\"><w:name w:val=\"First Paragraph\"/><w:basedOn w:val=\"BodyText\"/><w:next w:val=\"BodyText\"/><w:qFormat/>$body$RPR</w:style>"
replace_style Compact "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"Compact\"><w:name w:val=\"Compact\"/><w:basedOn w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"0\"/></w:pPr></w:style>"
for h in Heading1 Heading2 Heading3 Title; do
  replace_style "$h" "<w:style w:type=\"paragraph\" w:styleId=\"$h\"><w:name w:val=\"$h\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before=\"130\" w:after=\"130\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/></w:pPr><w:rPr>$FONTS<w:b/><w:color w:val=\"000000\"/><w:sz w:val=\"$SZ\"/><w:szCs w:val=\"$SZ\"/></w:rPr></w:style>"
done
replace_style FootnoteText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteText\"><w:name w:val=\"Footnote Text\"/><w:basedOn w:val=\"Normal\"/><w:qFormat/><w:pPr><w:spacing w:before=\"0\" w:after=\"100\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/></w:pPr><w:rPr>$FONTS<w:sz w:val=\"$SZ\"/><w:szCs w:val=\"$SZ\"/></w:rPr></w:style>"
# no table borders: the caption and attorney blocks are borderless tables (pandoc's Table style draws a rule under the first row)
replace_style Table '<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>'

# ---- custom paragraph styles used by the Lua filter (wyd.lua); names must match the custom-style attributes ----
sty() { # id, name, pPr inner xml, rPr inner xml (optional)
  printf '<w:style w:type="paragraph" w:customStyle="1" w:styleId="%s"><w:name w:val="%s"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>%s</w:pPr><w:rPr>%s%s</w:rPr></w:style>' "$1" "$2" "$3" "$FONTS" "${4:-}"
}
SINGLE='<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>'
add_style "$(sty Centered Centered "$SINGLE<w:jc w:val=\"center\"/>")"
add_style "$(sty Single Single "$SINGLE<w:jc w:val=\"left\"/>")"
add_style "$(sty SingleIndent "Single Indent" '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:firstLine="0"/>')"
add_style "$(sty Flush Flush "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"0\"/>")"
add_style "$(sty SigIndent "Signature Indent" '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="3600" w:firstLine="0"/>')"
add_style "$(sty KeepFlush "Keep Flush" '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/>')"
add_style "$(sty Served "Served Indent" '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/>')"
add_style "$(sty KeepBody "Keep Body" '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="720"/>')"
add_style "$(sty Keep "Keep Together" '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>')"
add_style "$(sty Lettered "Lettered Item" "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\"/><w:ind w:left=\"1440\" w:hanging=\"720\"/>")"
add_style "$(sty NumberedItem "Numbered Item" "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\"/><w:ind w:left=\"1224\" w:hanging=\"504\"/>")"
add_style "$(sty CenteredHeading "Centered Heading" '<w:keepNext/><w:keepLines/><w:spacing w:before="130" w:after="130" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>' '<w:b/>')"
add_style "$(sty HeadingFlush1 "Heading Flush 1" '<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="130" w:after="130" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="1"/>' '<w:b/>')"
add_style "$(sty HeadingFlush2 "Heading Flush 2" '<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:spacing w:before="130" w:after="130" w:line="240" w:lineRule="auto"/><w:ind w:left="1296" w:hanging="576"/><w:outlineLvl w:val="2"/>' '<w:b/>')"
add_style "$(sty Footer Footer "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/>")"
xmllint --noout "$ST"

# ---- footer with the page number (PAGE field; cached result 1) ----
cat > "$PKG/word/footer1.xml" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>}' "$PKG/word/_rels/document.xml.rels"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$PKG/[Content_Types].xml"

# ---- section: letter, 1 in margins, the footer (replaces pandoc's minimal sectPr) ----
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' "$PKG/word/document.xml"
grep -q 'xmlns:r=' "$PKG/word/document.xml" || { echo "build-reference.sh: document.xml has no r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels "[Content_Types].xml"; do
  xmllint --noout "$PKG/$part"
done

# ---- repack: [Content_Types].xml first, then everything else ----
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
rm -f "$OUT"
cd "$PKG"
set -- add_file "[Content_Types].xml" "$PKG/[Content_Types].xml" 0 "$(wc -c < "$PKG/[Content_Types].xml")"
for f in $(find _rels docProps word -type f | sort); do
  set -- "$@" add_file "$f" "$PKG/$f" 0 "$(wc -c < "$PKG/$f")"
done
ziptool -n "$OUT" "$@"
echo "$OUT"
