#!/bin/sh
# Builds docx/reference.docx for the utb motion with memorandum from pandoc's default reference, to the form of
# typst/utb-motion-brief.typ: EB Garamond 12 pt, exact 24 pt line pitch (double spacing), 0.5 in first-line
# indent (body paragraphs), 1.5 in top margin and 1 in other margins (letter), centred bold level-1 headings, bold left-aligned level-2 and level-3 headings, 12 pt
# single-spaced footnotes, and a bottom-centre page number (PAGE field in footer1.xml).
# Usage: sh docx/build-reference.sh <out.docx>
# Needs pandoc, ziptool (libzip) and xmllint on PATH; unzip and zip are not required.
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
for t in pandoc ziptool xmllint perl; do
  command -v "$t" > /dev/null || { echo "build-reference.sh: $t is not on PATH" >&2; exit 1; }
done
H2_JC=left
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
i=0
while ziptool "$W/ref.docx" stat "$i" > "$W/stat" 2> /dev/null; do
  name=$(sed -n "s/^name: '\(.*\)'$/\1/p" "$W/stat")
  mkdir -p "$W/pkg/$(dirname "$name")"
  ziptool "$W/ref.docx" cat "$i" > "$W/pkg/$name"
  i=$((i + 1))
done
P=$W/pkg
S=$P/word/styles.xml
DOC=$P/word/document.xml
# drop the pandoc styles this template sets (whole <w:style> elements), then append the template's own
perl -0pi -e 's{<w:style [^>]*w:styleId="(?:Normal|BodyText|FirstParagraph|Compact|Heading1|Heading2|Heading3|FootnoteText)".*?</w:style>}{}sg' "$S"
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
RPR="<w:rPr>$FONT<w:color w:val=\"000000\"/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>"
BOLD="<w:rPr>$FONT<w:b/><w:bCs/><w:color w:val=\"000000\"/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>"
EXACT='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
SINGLE='<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
cat > "$W/styles-add.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$EXACT<w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr>$RPR</w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr>$BOLD</w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="$H2_JC"/><w:outlineLvl w:val="1"/></w:pPr>$BOLD</w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr>$BOLD</w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeepNext"><w:name w:val="Body Keep Next"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine="0"/></w:pPr><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
XML
ADD="$W/styles-add.xml" perl -0pi -e 'local $/; open my $f, "<", $ENV{ADD} or die "styles-add: $!"; my $add = <$f>; s{</w:styles>}{$add</w:styles>}' "$S"
# footer: the PAGE field (cached result 1), centred, 12 pt
FRPR="<w:rPr>$FONT<w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>"
cat > "$P/word/footer1.xml" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center"/>$SINGLE</w:pPr><w:r>$FRPR<w:fldChar w:fldCharType="begin"/></w:r><w:r>$FRPR<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>$FRPR<w:fldChar w:fldCharType="separate"/></w:r><w:r>$FRPR<w:t>1</w:t></w:r><w:r>$FRPR<w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Id="rIdFtr1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>}' "$P/word/_rels/document.xml.rels"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$P/[Content_Types].xml"
# body section: letter, 1.5 in top, 1 in other margins, the page-number footer
perl -0pi -e 's{<w:sectPr.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>}s' "$DOC"
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$P/$part"
done
# the archive: [Content_Types].xml first, then every other part
rm -f "$OUT"
cd "$P"
ziptool -n -t "$OUT" add '[Content_Types].xml' "$(cat '[Content_Types].xml')"
find . -type f | sed 's|^\./||' | grep -v -x -F '[Content_Types].xml' | sort | while IFS= read -r p; do
  ziptool "$OUT" add "$p" "$(cat "$p")"
done
echo "$OUT"
