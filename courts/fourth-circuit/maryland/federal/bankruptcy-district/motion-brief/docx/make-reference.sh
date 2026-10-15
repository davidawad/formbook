#!/bin/sh
# Builds docx/reference.docx for the mdb memorandum in support of a motion from pandoc's default reference document.
# The form follows typst/mdb-motion-brief.typ (the mandated form and the caption, see ../README.md "Engines"):
#   EB Garamond 12 pt throughout; body double-spaced on a 24 pt exact pitch, first line indented 0.5 in;
#   headings on the same pitch, bold: level 1 centered and underlined in capitals (the capitals are made by the
#   Lua filter, the style underlines), level 2 and level 3 bold at the margin; block quotations single-spaced
#   (14 pt exact) and indented 0.5 in on both sides; the Certificate of Service starts a new page; letter page,
#   1-inch margins; centered page number in the footer (PAGE field, 12 pt, the first page included).
# Usage: sh docx/make-reference.sh [out.docx]
# Needs: pandoc, perl, unzip, zip, xmllint. The cover, the caption table and the signature block are written by
# docx/mdb-motion-brief.lua, not here.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />'

cat > "$T/defaults.xml" <<XML
<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>
XML

# Line pitch: 480 twips (24 pt) exact for double spacing; 280 (14 pt) for single.
cat > "$T/styles.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:widowControl /><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr>$FONT<w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:widowControl /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:widowControl /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="280" w:lineRule="exact" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr>$FONT<w:b /><w:bCs /><w:sz w:val="24" /><w:szCs w:val="24" /><w:u w:val="single" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr>$FONT<w:b /><w:bCs /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr>$FONT<w:b /><w:bCs /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepNextBody"><w:name w:val="Keep Next Body" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertificateHeading"><w:name w:val="Certificate Heading" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:pageBreakBefore /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr>$FONT<w:b /><w:bCs /><w:sz w:val="24" /><w:szCs w:val="24" /><w:u w:val="single" /></w:rPr></w:style>
XML

NEWSTYLES="$T/styles.xml" DEFAULTS="$T/defaults.xml" perl -0pi -e '
  my ($new, $dd) = map { local $/; open(my $fh, "<", $_) or die "$_: $!"; <$fh> } ($ENV{NEWSTYLES}, $ENV{DEFAULTS});
  for my $id (qw(Normal BodyText FirstParagraph Compact BlockText Heading1 Heading2 Heading3 KeepNextBody CertificateHeading)) {
    s{<w:style [^>]*w:styleId="$id".*?</w:style>\s*}{}s;
  }
  s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s;
  s{</w:styles>}{$new</w:styles>}s;
' "$W/word/styles.xml"

cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML

perl -0pi -e '
  s{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /></w:sectPr>}s;
' "$W/word/document.xml"
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
