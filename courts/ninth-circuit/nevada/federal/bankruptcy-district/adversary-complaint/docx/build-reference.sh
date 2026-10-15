#!/bin/sh
# Builds docx/reference.docx for nvb (D. Nev. Bankruptcy) pleadings from pandoc's default reference.
# Form (typst/nvb-*.typ, LR 9004): US Letter; top margin 1 in (line 1 on the top margin); 28 lines of 24 pt
# exact pitch from the top margin; left margin 1.5 in; right 0.75 in; bottom margin 48 pt (holds the page
# number); EB Garamond 13 pt (LR 9004(b): 12 pt or larger); double spacing = exact 24 pt; single spacing for
# the caption, counsel block, quotations, footnotes and signature block = exact 15 pt; the 28 line numbers are
# a text box anchored to the page in the header (fixed at 28 per page, whatever the text does); one vertical rule left of the text;
# consecutive page numbers centered in the footer.
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, unzip, zip, xmllint, perl, seq on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" "$W/s"
cd "$W/pkg" && unzip -q ../ref.docx

# one style per file, replacing pandoc's style of the same id (or appending a new one)
cat > "$W/setstyle.pl" <<'PL'
my ($file, $id, $new) = @ARGV;
local $/;
open my $fh, '<', $file or die; my $s = <$fh>; close $fh;
open my $nh, '<', $new or die; my $n = <$nh>; close $nh; $n =~ s/\s+\z//;
if ($s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$n}s) { } else { $s =~ s{</w:styles>}{$n\n</w:styles>} or die "no </w:styles>" }
open my $oh, '>', $file or die; print $oh $s; close $oh;
PL

PARA_BASE='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>'
SINGLE='<w:spacing w:before="0" w:after="0" w:line="300" w:lineRule="exact"/>'

cat > "$W/s/Normal.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$PARA_BASE<w:ind w:firstLine="0"/></w:pPr></w:style>
XML
cat > "$W/s/BodyText.xml" <<XML
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:widowControl/>$PARA_BASE<w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
XML
cat > "$W/s/FirstParagraph.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl/>$PARA_BASE<w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
XML
# block quotations: single-spaced, indented 0.5 in on both sides (LR 9004(a) exempts quotations)
cat > "$W/s/BlockText.xml" <<XML
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:widowControl/>$SINGLE<w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
XML
# headings: double-spaced lines, kept with the next paragraph; level 1 and 2 centered bold, level 3 run-in bold
for n in 1 2; do
  cat > "$W/s/Heading$n.xml" <<XML
<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading${n}Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:widowControl/>$PARA_BASE<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="$((n - 1))"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
XML
done
cat > "$W/s/Heading3.xml" <<XML
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:widowControl/>$PARA_BASE<w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
XML
# footnotes: single-spaced, 13 pt (LR 9004(b) sets 12 pt as the floor, footnotes included)
cat > "$W/s/FootnoteText.xml" <<XML
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
XML
# custom paragraph styles used by the Lua filter
cat > "$W/s/Single.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
XML
cat > "$W/s/NumberedParagraph.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl/><w:tabs><w:tab w:val="left" w:pos="1152"/></w:tabs>$PARA_BASE<w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
XML
cat > "$W/s/LetteredItem.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="LetteredItem"><w:name w:val="Lettered Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs>$PARA_BASE<w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/></w:pPr></w:style>
XML
cat > "$W/s/BulletItem.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BulletItem"><w:name w:val="Bullet Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$PARA_BASE<w:ind w:left="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
XML
cat > "$W/s/SigLine.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLine"><w:name w:val="Signature Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SINGLE<w:ind w:left="4896" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
XML
for f in "$W"/s/*.xml; do
  perl "$W/setstyle.pl" word/styles.xml "$(basename "$f" .xml)" "$f"
done

# document defaults: EB Garamond 13 pt, exact double spacing, no space after
perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>}s' word/styles.xml

# header: the 28 pleading line numbers, in a text box anchored to the page at the top margin (a Word
# pleading-paper text box). One paragraph per line, exact 24 pt pitch, right-aligned, 12 pt. The box is
# behind the text and takes no space in the header, so the body keeps its full 28-line text area.
{
  echo '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  echo '<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">'
  echo '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r><w:rPr><w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0" relativeHeight="251659264" behindDoc="1" locked="1" layoutInCell="1" allowOverlap="1"><wp:simplePos x="0" y="0"/><wp:positionH relativeFrom="page"><wp:posOffset>0</wp:posOffset></wp:positionH><wp:positionV relativeFrom="page"><wp:posOffset>914400</wp:posOffset></wp:positionV><wp:extent cx="987425" cy="8534400"/><wp:effectExtent l="0" t="0" r="0" b="0"/><wp:wrapNone/><wp:docPr id="101" name="Pleading line numbers"/><wp:cNvGraphicFramePr/><a:graphic><a:graphicData uri="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"><wps:wsp><wps:cNvSpPr txBox="1"/><wps:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="987425" cy="8534400"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></wps:spPr><wps:txbx><w:txbxContent>'
  for i in $(seq 1 28); do
    printf '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>%s</w:t></w:r></w:p>\n' "$i"
  done
  echo '</w:txbxContent></wps:txbx><wps:bodyPr rot="0" vert="horz" wrap="square" lIns="0" tIns="0" rIns="0" bIns="0" anchor="t" anchorCtr="0"><a:noAutofit/></wps:bodyPr></wps:wsp></a:graphicData></a:graphic></wp:anchor></w:drawing></w:r></w:p>'
  echo '</w:hdr>'
} > word/header1.xml

# footer: consecutive page number (PAGE field), 12 pt, centered
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Id="rIdNvbHdr1" Target="header1.xml"/><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdNvbFtr1" Target="footer1.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"/><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'

# section: letter, margins as above (top 1 in; bottom 48 pt so 28 x 24 pt lines fill the text area), a left
# rule at 14 pt outside the text (offsetFrom text), header and footer parts
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:headerReference w:type="default" r:id="rIdNvbHdr1"/><w:footerReference w:type="default" r:id="rIdNvbFtr1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="480" w:gutter="0"/><w:pgBorders w:offsetFrom="text"><w:left w:val="single" w:sz="6" w:space="14" w:color="000000"/></w:pgBorders><w:cols w:space="720"/></w:sectPr>}s' word/document.xml

for part in word/styles.xml word/document.xml word/header1.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
