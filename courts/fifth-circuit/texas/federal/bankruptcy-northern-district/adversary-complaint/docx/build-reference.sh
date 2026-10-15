#!/bin/sh
# Builds docx/reference.docx for a txnb (N.D. Tex. bankruptcy) doc type, from pandoc's default reference.
# Matches the typst template (typst/txnb-*.typ): US Letter, 1 in margins, EB Garamond 12 pt, 24 pt (exact)
# double-spaced body (24 pt pitch: proportional 369/240 of EB Garamond's line height) with 0.5 in first-line indent, single-spaced cover, centered bold Heading 1,
# bold Heading 2, bold italic Heading 3, page number 10 pt centered in the footer.
# Fonts are named explicitly (no theme font references) in the styles and in the theme.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT="$(pwd)/$OUT" ;; esac
FONT="EB Garamond"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
RF="<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/>"

# 1. styles: no theme font or theme colour references anywhere
perl -pi -e 's/ w:(ascii|hAnsi|eastAsia|cs)Theme="[^"]*"//g; s/ w:themeColor="[^"]*"//g; s/ w:themeShade="[^"]*"//g; s/ w:themeTint="[^"]*"//g' word/styles.xml
# drop the style definitions this reference replaces (each is re-added below with explicit values)
for id in Normal BodyText FirstParagraph Compact Title Heading1 Heading2 Heading3 Heading4 Heading5 Heading6 Heading7 Heading8 Heading9 FootnoteText BlockText Hyperlink FootnoteReference Heading1Char Heading2Char Heading3Char Heading4Char Heading5Char Heading6Char Heading7Char Heading8Char Heading9Char TitleChar SubtitleChar Caption; do
  ID=$id perl -0pi -e 's{<w:style [^>]*w:styleId="$ENV{ID}"[^>]*>.*?</w:style>}{}s' word/styles.xml
done
perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>'"$RF"'<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s' word/styles.xml
SP='<w:spacing w:before="0" w:after="0" w:line="369" w:lineRule="auto"/>'
S1='<w:spacing w:before="120" w:after="0" w:line="369" w:lineRule="auto"/>'
cat > "$W/styles-add.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$SP<w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl/>$SP<w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$SP<w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NoIndent"><w:name w:val="No Indent"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$SP<w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$SP<w:tabs><w:tab w:val="left" w:pos="1080"/></w:tabs><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBold"><w:name w:val="Centered Bold"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="369" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertBody"><w:name w:val="Certificate Body"/><w:basedOn w:val="NoIndent"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$SP<w:tabs><w:tab w:val="left" w:pos="1584"/></w:tabs><w:ind w:left="1584" w:hanging="864"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListContinue"><w:name w:val="List Continue"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$SP<w:ind w:left="1584" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="0" w:line="369" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="0" w:line="369" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="0" w:line="369" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4320" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="center" w:pos="4680"/><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr>$RF<w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
XML
ADD="$W/styles-add.xml" perl -0pi -e 'my $a = do { local $/; open my $f, "<", $ENV{ADD} or die; <$f> }; s{</w:styles>}{$a</w:styles>}' word/styles.xml
xmllint --noout word/styles.xml

# 2. theme: body and heading faces are the court face (Word and LibreOffice read the theme for theme-named fonts)
perl -0pi -e 's{(<a:(?:major|minor)Font>\s*<a:latin typeface=")[^"]*"}{$1'"$FONT"'"}g' word/theme/theme1.xml
xmllint --noout word/theme/theme1.xml

# 3. footer: PAGE field, 10 pt, centered; page setup: US Letter, 1 in margins
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
grep -q 'footer1.xml' word/_rels/document.xml.rels || sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml"/></Relationships>|' word/_rels/document.xml.rels
grep -q 'footer1.xml' '[Content_Types].xml' || sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="FOOTDIST" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>}s' word/document.xml
perl -pi -e "s/FOOTDIST/810/" word/document.xml
grep -q 'xmlns:r=' word/document.xml || perl -0pi -e 's/<w:document /<w:document xmlns:r="http:\/\/schemas.openxmlformats.org\/officeDocument\/2006\/relationships" /' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/theme/theme1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done


rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
