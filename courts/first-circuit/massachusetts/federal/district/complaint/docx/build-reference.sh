#!/bin/sh
# Builds docx/reference.docx for the D. Mass. complaint from pandoc's default reference.docx.
# Form (matches typst/mad-complaint.typ, as typst renders it): EB Garamond 13 pt (vendored); body lines at a 24 pt
# pitch (auto spacing, 341/240 of the font's 16.95 pt line, so the glyphs sit at the top of the line like typst);
# headings at a 16.9 pt pitch (exact 338), 18 pt caps (level 1) and 15.5 pt bold (level 2), as typst sizes them at
# 1.4em and 1.2em; single lines at 14.3 pt (exact 286); 1 in margins on US Letter; 0.5 in first-line indent;
# page number centered in the footer at 12 pt. Styles only: no tabs or spaces for indents, no explicit line breaks.
# Word numbering is added by docx/render.sh (pandoc rewrites numbering.xml), so this file has no numbering.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip on PATH; xmllint optional)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx

# replace one style by its styleId (the whole <w:style> element)
rep() {
  ID=$1 NEW=$2 perl -0pi -e 's{<w:style [^>]*w:styleId="$ENV{ID}"[^>]*>.*?</w:style>}{$ENV{NEW}}s' word/styles.xml
  grep -q "w:styleId=\"$1\"" word/styles.xml || { echo "build-reference: style $1 missing" >&2; exit 1; }
}
# add a style at the end of styles.xml
add() {
  NEW=$1 perl -0pi -e 's{</w:styles>}{$ENV{NEW}</w:styles>}' word/styles.xml
}

DOCDEF='<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="341" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>'
ID=x NEW=$DOCDEF perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{$ENV{NEW}}s' word/styles.xml

rep Normal '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/><w:spacing w:before="0" w:after="0" w:line="341" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>'
rep BodyText '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="341" w:lineRule="auto"/><w:ind w:firstLine="720"/><w:jc w:val="both"/></w:pPr></w:style>'
rep Compact '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="312" w:line="341" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>'
rep Heading1 '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="338" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr></w:style>'
rep Heading2 '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="338" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="31"/><w:szCs w:val="31"/></w:rPr></w:style>'
rep Heading3 '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="341" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>'
rep BlockText '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="78" w:after="480" w:line="286" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="both"/></w:pPr></w:style>'
rep FootnoteText '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="264" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'

# custom styles (the names are the styleIds without spaces, as pandoc's custom-style attribute needs)
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleLine"><w:name w:val="Single Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="286" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredSingle"><w:name w:val="Centered Single"/><w:basedOn w:val="SingleLine"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="CenteredSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionVs"><w:name w:val="Caption Vs"/><w:basedOn w:val="SingleLine"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation"/><w:basedOn w:val="SingleLine"/><w:qFormat/><w:pPr><w:ind w:left="1800" w:firstLine="0"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapBody"><w:name w:val="Gap Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapSig"><w:name w:val="Gap Sig"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="195" w:lineRule="exact"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="JuryDemand"><w:name w:val="Jury Demand"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapDouble"><w:name w:val="Gap Double"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="624" w:lineRule="exact"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigIndent"><w:name w:val="Sig Indent"/><w:basedOn w:val="SingleLine"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4320" w:firstLine="0"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:numPr><w:numId w:val="9001"/></w:numPr><w:spacing w:before="0" w:after="0" w:line="341" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="720"/><w:jc w:val="both"/></w:pPr></w:style>'
add '<w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerItem"><w:name w:val="Prayer Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:numPr><w:numId w:val="9002"/></w:numPr><w:spacing w:before="0" w:after="0" w:line="341" w:lineRule="auto"/><w:ind w:left="1296" w:hanging="576"/><w:jc w:val="both"/></w:pPr></w:style>'


# hyphenation as typst (justified text is hyphenated): Word and LibreOffice read this document setting
perl -0pi -e 's{(<w:defaultTabStop[^>]*/>)}{$1<w:autoHyphenation/>}' word/settings.xml
# footnotes and other parts keep pandoc's defaults; the footer carries the page number (PAGE field, cached 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'

# body section: US Letter, 1 in margins, the footer
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
SECT=$SECT perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{$ENV{SECT}}s' word/document.xml

if command -v xmllint > /dev/null; then
  for part in word/styles.xml word/numbering.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
fi
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
