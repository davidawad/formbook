#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference to match typst/laed-complaint.typ (LR 10.1):
# EB Garamond 12 pt, exact 24 pt (double) line pitch, 0.5 in first-line indent, letter page with 1 in margins,
# page number centered in a footer 0.6 in from the bottom edge, none on page 1 (titlePg).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, zip, unzip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/fix-styles.pl" <<'PERL'
# Replace the pandoc styles the court's form sets, and add the custom ones the filter uses.
s{<w:rFonts w:asciiTheme="minorHAnsi"[^>]*/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>}s;
s{<w:spacing w:after="200" />}{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />}s;
for my $id (qw(BodyText Heading1 Heading2 Heading3 BlockText FootnoteText)) {
  s{<w:style [^>]*w:styleId="\Q$id\E">.*?</w:style>}{}s;
}
my $body = q{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>};
my $single = q{<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>};
my $fonts = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>};
my $new = join "", map { "$_\n" } (
  qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr>$body<w:ind w:firstLine="720"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$body<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$fonts<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$body<w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$fonts<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$body<w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$fonts<w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$single<w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr>$single<w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$single<w:ind w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredDouble"><w:name w:val="Centered Double"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$body<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$body<w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="4320" w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionText"><w:name w:val="Caption Text"/><w:basedOn w:val="Single"/><w:qFormat/></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionIndent"><w:name w:val="Caption Indent"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>},
  qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="2160" w:firstLine="0"/></w:pPr></w:style>},
);
s{</w:styles>}{$new</w:styles>}s;
PERL
perl -0777 -pi "$W/fix-styles.pl" word/styles.xml
# body section: letter, 1 in margins, footer 0.6 in from the bottom edge, the page number from page 2 (titlePg)
perl -0777 -pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId900"/><w:footerReference w:type="first" r:id="rId901"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="864" w:gutter="0"/><w:titlePg/></w:sectPr>}s' word/document.xml
# footers: the default one carries the PAGE field (cached result 1); the first-page one is empty
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>2</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > word/footer2.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId900" Target="footer1.xml"/><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId901" Target="footer2.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
