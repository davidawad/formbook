#!/bin/sh
# Builds docx/reference.docx for the D. Conn. memorandum of law (docs/DOCX.md). It starts from pandoc's default
# reference and replaces the styles it uses with the layout of typst/ctd-motion-brief.typ: US Letter, 1 in on every
# side, EB Garamond 12 pt; body double spaced as an exact 27.6 pt line (552 twips), paragraphs with a 0.5 in first
# line indent and no extra space between them; headings, footnotes, block quotations, counsel, caption and signature
# blocks single spaced (exact 13.8 pt, 276 twips; footnotes at 10 pt). Level 1 headings centred and bold caps; level 2
# to 4 bold with the label hanging (A., 1., a.). Sections: the cover (no page number), the table of contents and the
# table of authorities (lower-case roman, i, ii), the body (arabic from 1). The section breaks are written by
# complaint-style raw OpenXML from motion-brief.lua; the footers are: footer1 (page number), footer2 (cover, empty
# except for the oral-argument legend that docx/render.sh fills in).
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, xmllint, perl)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
cat > "$W/styles-new.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>${FONT}<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="100" w:after="100" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>${FONT}<w:b/><w:bCs/><w:caps/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="100" w:after="100" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>${FONT}<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="100" w:after="100" w:line="276" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>${FONT}<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="2160"/></w:tabs><w:spacing w:before="100" w:after="100" w:line="276" w:lineRule="exact"/><w:ind w:left="2160" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr>${FONT}<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="180" w:after="60" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PleadingSingle"><w:name w:val="Pleading Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontHeading"><w:name w:val="Front Heading"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="276" w:after="276" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ItemList"><w:name w:val="Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1584"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1584" w:hanging="864"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TocEntry"><w:name w:val="Toc Entry"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="108" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TableAuthority"><w:name w:val="Table Authority"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="40" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="504" w:right="360" w:hanging="504"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="AuthorityGroup"><w:name w:val="Authority Group"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="60" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="PleadingSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:firstLine="0"/></w:pPr></w:style>
XML
# replace the styles of the same id (and the document defaults, which carry the theme font), then append the rest
perl -0777 -i -pe '
  open my $f, "<", "$ENV{W}/styles-new.xml" or die; my $new = do { local $/; <$f> };
  my @ids = $new =~ /w:styleId="([^"]+)"/g;
  for my $id (@ids) { s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s; }
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  s{</w:styles>}{$new</w:styles>}s;
' word/styles.xml
# no style may name a theme font: a theme font would replace EB Garamond in Word and in LibreOffice
perl -0777 -i -pe 's{ w:(ascii|hAnsi|eastAsia|cs)Theme="[^"]*"}{}g' word/styles.xml
xmllint --noout word/styles.xml

# footer1: the page number, centred ("1" is the cached PAGE result; the format comes from each section's pgNumType)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
# footer2: the cover: no page number; the oral-argument legend (bold, at the left, in the lower margin) when the sample has one
cat > word/footer2.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:r><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/></w:rPr><w:t>@COVER_LEGEND@</w:t></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId101" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer2.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# the body section (the last one in the document: the memorandum): letter, 1 in margins, arabic page numbers from 1.
# motion-brief.lua writes the section breaks before the table of contents and before the table of authorities
# and after the cover (raw OpenXML sectPr in those paragraphs), so the final sectPr is the body's.
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId101"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>'
SECT="$SECT" perl -0777 -i -pe 's{<w:sectPr\b.*?</w:sectPr>}{}s; s{</w:body>}{$ENV{SECT}</w:body>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
