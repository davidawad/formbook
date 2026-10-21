#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the SCOTUS cert petition (Rule 33.1, booklet format).
# Mirrors typst/scotus-cert-petition-cert-petition.typ: TeX Gyre Schola (Century family, Rule 33.1(b)) 12 pt on exact
# 14 pt lines (12 pt + 2 pt leading), justified, 0.5 in first-line indent, 0.9 em (10.8 pt) between paragraphs; headings
# centred bold (level 1), bold with a 0.4 in hanging indent (level 2), bold italic (level 3); footnotes 10 pt on 12 pt lines;
# block quotations indented 0.5 in on both sides. Page: 6 1/8 x 9 1/4 in, text field 4 1/8 x 7 1/8 in.
# The cover, caption, counsel, front pages, tables of contents and authorities, signature and certificate are written
# by scotus.lua with the custom styles defined here. Page geometry is set by scotus.lua, the footers by fb render.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, sed, unzip, zip, xmllint, perl on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
FONT="TeX Gyre Schola"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
S=word/styles.xml
# 1. drop the pandoc styles this template redefines (each block runs from its opening tag to </w:style>)
for id in Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 BlockText FootnoteText; do
  sed -i "/<w:style [^>]*w:styleId=\"$id\"/,/<\/w:style>/d" "$S"
done
# 2. theme and default fonts become the court font (rFonts elements may span lines: slurp the file first)
perl -0pi -e "s{<w:rFonts\\b[^>]*/>}{<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/>}g" "$S"
# 3. the styles this template uses (appended before </w:styles>)
cat > "$W/new-styles.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="216" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="both"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:after="0"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="288" w:after="216" w:line="376" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="33"/><w:szCs w:val="33"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="168" w:line="328" w:lineRule="exact"/><w:ind w:left="576" w:hanging="576"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="216" w:after="144" w:line="280" w:lineRule="exact"/><w:ind w:left="576" w:hanging="576"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="216" w:after="216" w:line="270" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverLine"><w:name w:val="Cover Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="260" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselLine"><w:name w:val="Counsel Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="3078"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLine"><w:name w:val="Signature Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenterLine"><w:name w:val="Center Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="240" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertBody"><w:name w:val="Certificate Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="both"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertSig"><w:name w:val="Certificate Signature"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontHeading"><w:name w:val="Front Heading"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="288" w:after="216" w:line="376" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="33"/><w:szCs w:val="33"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry1"><w:name w:val="TOC Entry 1"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="5940"/></w:tabs><w:spacing w:before="0" w:after="120" w:line="280" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry2"><w:name w:val="TOC Entry 2"/><w:basedOn w:val="TOCEntry1"/><w:qFormat/><w:pPr><w:ind w:left="432" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAGroup"><w:name w:val="TOA Group"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="120" w:line="280" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAEntry"><w:name w:val="TOA Entry"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="right" w:pos="5940"/></w:tabs><w:spacing w:before="120" w:after="0" w:line="280" w:lineRule="exact"/><w:ind w:left="432" w:hanging="432"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SectionEnd"><w:name w:val="Section End"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr></w:style>
</w:styles>
XML
grep -v '</w:styles>' "$S" > "$W/styles.new"
cat "$W/new-styles.xml" >> "$W/styles.new"
mv "$W/styles.new" "$S"
for part in word/styles.xml; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
