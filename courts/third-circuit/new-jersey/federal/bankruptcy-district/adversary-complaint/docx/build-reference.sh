#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the New Jersey bankruptcy court (njb).
# Matches the typst template (typst/njb-*.typ) in courts/third-circuit/new-jersey/federal/bankruptcy-district:
#   EB Garamond 14 pt body; exact 25.2 pt (504 twips) line pitch and 9.8 pt paragraph gap (0.7 em) measured on
#   the typst output; single lines at exact 15.4 pt (308 twips) for counsel, caption and signature blocks;
#   letter paper, 1 in margins; centered 12 pt page number in the footer; footnote text 12 pt, single spaced.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, and ziptool from libzip on PATH)
set -eu
OUT=$1
FONT="EB Garamond"
BODY_SZ=28          # half-points (14 pt)
HEAD1_SZ=26         # 13 pt, centered, caps
FOOT_SZ=24          # 12 pt: page number and footnotes
LINE=504            # exact body pitch, twips (25.2 pt)
SINGLE=308          # exact single pitch, twips (15.4 pt)
AFTER=196           # 0.7 em paragraph gap, twips (9.8 pt)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
# zip helpers: unpack every entry by index, pack in order with [Content_Types].xml first
unpack() {
  i=0
  while ziptool "$1" stat "$i" >/dev/null 2>&1; do
    n=$(ziptool "$1" stat "$i" | tr '\n' ' ' | sed "s/^name: '\([^']*\)'.*/\1/")
    mkdir -p "$2/$(dirname "$n")"
    ziptool "$1" cat "$i" > "$2/$n"
    i=$((i + 1))
  done
}
pack() {
  rm -f "$2"
  { echo '[Content_Types].xml'; (cd "$1" && find . -type f | sed 's|^\./||' | sort | grep -v '^\[Content_Types\]\.xml$'); } |
    while IFS= read -r n; do ziptool "$2" add_file "$n" "$1/$n" 0 0 >/dev/null; done
}
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
unpack "$W/ref.docx" "$W/pkg"
cd "$W/pkg"
# 1. document defaults: EB Garamond at the body size, no theme fonts, no space after
perl -0pi -e "s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/><w:sz w:val=\"$BODY_SZ\"/><w:szCs w:val=\"$BODY_SZ\"/><w:lang w:val=\"en-US\" w:eastAsia=\"en-US\" w:bidi=\"ar-SA\"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after=\"0\"/></w:pPr></w:pPrDefault></w:docDefaults>}s" word/styles.xml
# 2. drop the pandoc paragraph styles we redefine (theme fonts and blue headings in the default)
perl -0pi -e 's{<w:style [^>]*w:styleId="(Normal|BodyText|FirstParagraph|Compact|Title|Heading1|Heading2|Heading3|FootnoteText)".*?</w:style>}{}gs' word/styles.xml
# 3. the paragraph styles, black, in EB Garamond, with the typst spacing
cat > "$W/styles-add.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="$FONT" w:hAnsi="$FONT" w:eastAsia="$FONT" w:cs="$FONT"/><w:sz w:val="$BODY_SZ"/><w:szCs w:val="$BODY_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="$AFTER" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:after="0"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:after="$AFTER" w:line="$LINE" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:sz w:val="$BODY_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="260" w:after="208" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:caps/><w:color w:val="000000"/><w:sz w:val="$HEAD1_SZ"/><w:szCs w:val="$HEAD1_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="252" w:after="168" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:color w:val="000000"/><w:sz w:val="$BODY_SZ"/><w:szCs w:val="$BODY_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="224" w:after="168" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:i/><w:color w:val="000000"/><w:sz w:val="$BODY_SZ"/><w:szCs w:val="$BODY_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="60" w:line="$SINGLE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$FOOT_SZ"/><w:szCs w:val="$FOOT_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="$FOOT_SZ"/><w:szCs w:val="$FOOT_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$SINGLE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Note"><w:name w:val="Note"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="$AFTER" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:i/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Numbered"><w:name w:val="Numbered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1368"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1296"/></w:tabs><w:spacing w:after="$AFTER"/><w:ind w:left="1296" w:hanging="576"/></w:pPr></w:style>
XML
ADD="$W/styles-add.xml" perl -0pi -e 'BEGIN{ local $/; open F, "<", $ENV{ADD}; $add = <F>; close F } s{</w:styles>}{$add</w:styles>}' word/styles.xml
# 4. footer with the page number (PAGE field, cached result 1)
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' '[Content_Types].xml'
# 5. section: letter, 1 in margins, the page-number footer
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
pack "$W/pkg" "$OUT"
echo "$OUT"
