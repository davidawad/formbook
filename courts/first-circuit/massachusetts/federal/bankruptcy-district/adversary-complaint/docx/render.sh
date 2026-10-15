#!/bin/sh
# DOCX engine for the mab adversary complaint (tools/render-docx.sh hands over here: docs/DOCX.md).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# 1. pandoc, with docx/reference.docx (styles) and docx/mab.lua (cover, caption, signature, numbering of allegations).
# 2. Post-processing that pandoc cannot do from a reference: the section (Letter, 1 in margins, page numbers
#    from page 2 via titlePg and an empty first-page footer), and the numbering definition the "Numbered
#    Paragraph" style refers to (MLBR Appendix 8(b); Fed. R. Civ. P. 10(b)).
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D="$COURT/docx"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/mab.lua" "$SAMPLE" -o "$W/pandoc.docx")
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/pandoc.docx"

# footers: the page number (PAGE field) and an empty first-page footer
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > word/footer2.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdMabFtr1" Target="footer1.xml"/><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdMabFtr2" Target="footer2.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'

# section: Letter, 1 in margins, footers as above (replaces pandoc's empty sectPr)
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdMabFtr1"/><w:footerReference w:type="first" r:id="rIdMabFtr2"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:titlePg/></w:sectPr>'
SECT="$SECT" perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{$ENV{SECT}}s' word/document.xml

# numbering: decimal "%1." at 0.5 in, tab to 1.0 in, wrapped lines flush left; the abstractNum goes before the w:num entries
cat > "$W/abstract.xml" <<'XML'
<w:abstractNum w:abstractNumId="9001"><w:multiLevelType w:val="singleLevel"/><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="decimal"/><w:pStyle w:val="NumberedParagraph"/><w:lvlText w:val="%1."/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="1440"/></w:tabs><w:ind w:left="0" w:firstLine="720"/></w:pPr></w:lvl></w:abstractNum>
XML
printf '<w:num w:numId="9001"><w:abstractNumId w:val="9001"/></w:num>\n' > "$W/num.xml"
ABS="$W/abstract.xml" perl -0pi -e 'BEGIN { local $/; open my $f, "<", $ENV{ABS} or die; $add = <$f>; } s{(<w:num )}{$add$1}' word/numbering.xml
NUM="$W/num.xml" perl -0pi -e 'BEGIN { local $/; open my $f, "<", $ENV{NUM} or die; $add = <$f>; } s{</w:numbering>}{$add</w:numbering>}' word/numbering.xml

for part in word/document.xml word/numbering.xml word/footer1.xml word/footer2.xml; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" . -x '[Content_Types].xml'
echo "$OUT"
