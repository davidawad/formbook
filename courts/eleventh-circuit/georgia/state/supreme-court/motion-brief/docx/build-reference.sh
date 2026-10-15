#!/bin/sh
# Builds docx/reference.docx for a Georgia Supreme Court motion or petition (the 1.5-spaced family:
# motion-brief and petition-for-review). Starts from pandoc's default reference.docx and rewrites it to the
# typst template's measurements (motion-brief/typst/ga-motion-brief.typ): TeX Gyre Schola 13 pt, body lines
# 19.5 pt (1.5 em) with 7.8 pt after each paragraph, single lines 15.9 pt, footnotes 11 pt, letter paper,
# 1 in margins, a centered page number in the footer. Line heights are proportional ("auto") so that the first
# line of a page sits at the top margin, as it does in typst (docs/DOCX.md, "Known limits").
# The sections (cover, body) and the cover, closing and certificate are written by docx/ga-motion.lua.
# Usage: sh docx/build-reference.sh <out.docx>     (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
FONT="TeX Gyre Schola"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q ../ref.docx
RF="<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/>"
# the exact-height gaps (empty paragraphs), in twips: 12, 15, 10, 9, 8, 6, 4 hundredths of an em at 13 pt
gap() { echo "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"$1\"><w:name w:val=\"$1\"/><w:basedOn w:val=\"Normal\"/><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$2\" w:lineRule=\"exact\"/><w:ind w:firstLine=\"0\"/></w:pPr></w:style>"; }
cat > "$W/styles-new.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="156" w:line="384" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="234" w:after="156" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="494" w:after="104" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="454" w:after="78" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Heading3"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:outlineLvl w:val="3"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Heading1Body"><w:name w:val="Heading1Body"/><w:basedOn w:val="Heading1"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="522" w:after="156" w:line="312" w:lineRule="auto"/><w:outlineLvl w:val="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Heading2Body"><w:name w:val="Heading2Body"/><w:basedOn w:val="Heading2"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="422" w:after="104" w:line="312" w:lineRule="auto"/><w:outlineLvl w:val="1"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Heading3Body"><w:name w:val="Heading3Body"/><w:basedOn w:val="Heading3"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="370" w:after="78" w:line="312" w:lineRule="auto"/><w:outlineLvl w:val="2"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="203" w:line="312" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigSingle"><w:name w:val="SigSingle"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="RightSingle"><w:name w:val="RightSingle"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ClosingKeep"><w:name w:val="ClosingKeep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:after="0"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyNoIndent"><w:name w:val="BodyNoIndent"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Question"><w:name w:val="Question"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:after="203"/><w:ind w:left="720" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontTitle"><w:name w:val="FrontTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="208" w:line="312" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="SigBlock"/><w:basedOn w:val="SigSingle"/><w:qFormat/><w:pPr><w:ind w:right="3312" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyFirst"><w:name w:val="BodyFirst"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry"><w:name w:val="TOCEntry"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="384" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
$(gap Gap12 312)
$(gap Gap15 390)
$(gap Gap10 260)
$(gap Gap09 234)
$(gap Gap08 208)
$(gap Gap06 156)
$(gap Gap04 104)
XML
cat > "$W/docdefaults.xml" <<XML
<w:docDefaults><w:rPrDefault><w:rPr>$RF<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
XML
cat > "$W/fix-styles.pl" <<'PL'
# Replaces the named styles and docDefaults in word/styles.xml (see the shell script above).
local $/;
my ($file, $new, $defaults, @ids) = @ARGV;
open my $fh, "<", $new or die "cannot read $new"; my $n = <$fh>; close $fh;
open $fh, "<", $defaults or die "cannot read $defaults"; my $d = <$fh>; close $fh;
open $fh, "<", $file or die "cannot read $file"; my $s = <$fh>; close $fh;
for my $id (@ids) { $s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s; }
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$d}s or die "no docDefaults in $file";
$s =~ s{</w:styles>}{$n</w:styles>}s;
open $fh, ">", $file or die; print $fh $s; close $fh;
PL
perl "$W/fix-styles.pl" word/styles.xml "$W/styles-new.xml" "$W/docdefaults.xml" \
  Normal BodyText FirstParagraph Compact BlockText Heading1 Heading2 Heading3 Heading4 Heading1Body Heading2Body Heading3Body FootnoteText \
  Centered Single SigSingle RightSingle SigBlock ClosingKeep BodyNoIndent BodyFirst Question FrontTitle TOCEntry Gap12 Gap15 Gap10 Gap09 Gap08 Gap06 Gap04
xmllint --noout word/styles.xml
echo "styles: ok" >&2
# footer: the page number, centered, in the body font (the cover has no footer; see ga-brief.lua)
cat > word/footer-ga.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
xmllint --noout word/footer-ga.xml
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdGaFooter" Target="footer-ga.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer-ga.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'
# the body's own section (the last one in the document): arabic page numbers from 1, continuous footnotes
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdGaFooter"/><w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal"/><w:cols w:space="720"/></w:sectPr>}s' word/document.xml
xmllint --noout word/document.xml
cd "$W/pkg"
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
