#!/bin/sh
# Builds docx/reference.docx for a Georgia Supreme Court brief (double-spaced family: answering,
# opening, reply). Starts from pandoc's default reference.docx and rewrites it to the typst template's
# measurements (answering-brief/typst/ga-answering-brief.typ): TeX Gyre Schola 13 pt, exact line pitches
# (double 31.2 pt, tight 18.72 pt, single 15.6 pt, footnotes 13.2 pt), letter paper, 1 in margins,
# footnotes 11 pt, and a centered page number in the footer.
# The sections (cover, roman front matter, arabic body) are written by docx/ga-brief.lua, not here.
# Usage: sh docx/build-reference.sh <out.docx>     (needs pandoc, perl, unzip, zip on PATH)
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
cat > "$W/styles-new.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="614" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="290" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312" w:after="208" w:line="307" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="31"/><w:szCs w:val="31"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="286" w:after="40" w:line="307" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Heading3"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:outlineLvl w:val="3"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="260" w:after="260" w:line="307" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="307" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="307" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="307" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Indent"><w:name w:val="Indent"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapSmall"><w:name w:val="GapSmall"/><w:basedOn w:val="Gap"/><w:pPr><w:spacing w:line="208" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapLarge"><w:name w:val="GapLarge"/><w:basedOn w:val="Gap"/><w:pPr><w:spacing w:line="416" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapMid"><w:name w:val="GapMid"/><w:basedOn w:val="Gap"/><w:pPr><w:spacing w:line="572" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapXL"><w:name w:val="GapXL"/><w:basedOn w:val="Gap"/><w:pPr><w:spacing w:line="624" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontTitleTight"><w:name w:val="FrontTitleTight"/><w:basedOn w:val="FrontTitle"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="184" w:line="307" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Heading2Body"><w:name w:val="Heading2Body"/><w:basedOn w:val="Heading2"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="208" w:line="307" w:lineRule="auto"/><w:outlineLvl w:val="1"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Heading3Body"><w:name w:val="Heading3Body"/><w:basedOn w:val="Heading3"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="40" w:line="307" w:lineRule="auto"/><w:outlineLvl w:val="2"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigSingle"><w:name w:val="SigSingle"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ClosingKeep"><w:name w:val="ClosingKeep"/><w:basedOn w:val="BodyNoIndent"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapLargeKeep"><w:name w:val="GapLargeKeep"/><w:basedOn w:val="GapLarge"/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontTitle"><w:name w:val="FrontTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="312" w:line="307" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyNoIndent"><w:name w:val="BodyNoIndent"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyFirst"><w:name w:val="BodyFirst"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCEntry"><w:name w:val="TOCEntry"/><w:basedOn w:val="BodyNoIndent"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="614" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAEntry"><w:name w:val="TOAEntry"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="307" w:lineRule="auto"/><w:ind w:left="576" w:right="1440" w:hanging="576"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOACategory"><w:name w:val="TOACategory"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="120" w:after="0" w:line="307" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>

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
  Normal BodyText FirstParagraph Compact BlockText Heading1 Heading2 Heading3 Heading4 FootnoteText \
  Centered Single SigSingle ClosingKeep GapLargeKeep Heading2Body Heading3Body FrontTitleTight Indent Gap GapSmall GapMid GapLarge GapXL FrontTitle BodyNoIndent BodyFirst TOCEntry TOAEntry TOACategory
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
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdGaFooter"/><w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>}s' word/document.xml
xmllint --noout word/document.xml
cd "$W/pkg"
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
