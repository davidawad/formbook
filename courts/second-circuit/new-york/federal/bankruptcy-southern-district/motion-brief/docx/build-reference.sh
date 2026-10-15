#!/bin/sh
# Builds docx/reference.docx for nysb (S.D.N.Y. Bankruptcy) from pandoc's default reference, to the mandated form of
# typst/nysb-motion-brief.typ: EB Garamond 12 pt, double spacing (exact 27.6 pt; blocks follow with no added space, as in the typst template),
# single spacing (exact 13.8 pt) for counsel, caption, signature and footnotes (11 pt), first-line indent 0.5 in,
# 1 in margins on letter paper, a centered PAGE field in the footer. The cover, contents and section restarts are written
# by docx/nysb-motion-brief.lua (paragraph-level section properties), not here.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q "$W/ref.docx")
P="$W/pkg"

# Style definitions, one <w:style> per styleId; each replaces the reference's style of the same id (or is added).
cat > "$W/defs.xml" <<'DEFS'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyPara"><w:name w:val="Body Para"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyLast"><w:name w:val="Body Last"/><w:basedOn w:val="BodyPara"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumPara"><w:name w:val="Num Para"/><w:basedOn w:val="BodyPara"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumLast"><w:name w:val="Num Last"/><w:basedOn w:val="NumPara"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListLast"><w:name w:val="List Last"/><w:basedOn w:val="ListItem"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyPara"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="256" w:after="276" w:line="552" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyPara"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="396" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyPara"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="234" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleGap"><w:name w:val="Single Gap"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="80"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselFor"><w:name w:val="Counsel For"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="276"/></w:pPr><w:rPr><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtNameFirst"><w:name w:val="Court Name First"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="276"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtNameLast"><w:name w:val="Court Name Last"/><w:basedOn w:val="CourtNameFirst"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="276"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionName"><w:name w:val="Caption Name"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:pBdr><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr><w:ind w:right="216"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionDesignation"><w:name w:val="Caption Designation"/><w:basedOn w:val="CaptionName"/><w:qFormat/><w:pPr><w:spacing w:after="80"/><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionAgainst"><w:name w:val="Caption Against"/><w:basedOn w:val="CaptionName"/><w:qFormat/><w:pPr><w:spacing w:after="80"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionEnd"><w:name w:val="Caption End"/><w:basedOn w:val="CaptionDesignation"/><w:qFormat/><w:pPr><w:pBdr><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="11" w:color="000000"/></w:pBdr><w:spacing w:after="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRight"><w:name w:val="Caption Right"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="504"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRightGap"><w:name w:val="Caption Right Gap"/><w:basedOn w:val="CaptionRight"/><w:qFormat/><w:pPr><w:spacing w:after="276"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverTitle"><w:name w:val="Cover Title"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="552" w:after="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureLeft"><w:name w:val="Signature Left"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureRight"><w:name w:val="Signature Right"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="288"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureGap"><w:name w:val="Signature Gap"/><w:basedOn w:val="SignatureRight"/><w:qFormat/><w:pPr><w:spacing w:before="276"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCTitle"><w:name w:val="TOC Title"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="552"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC1"><w:name w:val="toc 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC2"><w:name w:val="toc 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC3"><w:name w:val="toc 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:uiPriority w:val="59"/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
DEFS

# Merge: drop each reference style with the same id, then append the new definition before </w:styles>.
cat > "$W/merge.pl" <<'PERL'
use strict; use warnings;
my ($styles, $defs) = @ARGV;
local $/;
open my $fh, '<', $styles or die "open $styles: $!"; my $s = <$fh>; close $fh;
open my $dh, '<', $defs or die "open $defs: $!"; my $d = <$dh>; close $dh;
$s =~ s{<w:rPrDefault>.*?</w:rPrDefault>}{<w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>}s or die "no rPrDefault";
$s =~ s{<w:pPrDefault>.*?</w:pPrDefault>}{<w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault>}s or die "no pPrDefault";
while ($d =~ m{(<w:style [^>]*w:styleId="([^"]+)".*?</w:style>)}sg) {
  my ($frag, $id) = ($1, $2);
  my $n = ($s =~ s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>[ \t]*\n?}{}s);
  $s =~ s{</w:styles>}{$frag\n</w:styles>}s or die "no </w:styles>";
}
open my $oh, '>', $styles or die "write $styles: $!"; print {$oh} $s; close $oh;
PERL
perl "$W/merge.pl" "$P/word/styles.xml" "$W/defs.xml"

# Section: letter, 1 in margins, the PAGE footer, Arabic numbering from 1 (the body). Footnote numbering runs on.
perl -0777 -pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' "$P/word/document.xml"
grep -q 'footerReference w:type="default" r:id="rId100"' "$P/word/document.xml"

# Footer: the page number, centered, in the footer style.
cat > "$P/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' "$P/word/_rels/document.xml.rels"
perl -0777 -pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' "$P/[Content_Types].xml"

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels "[Content_Types].xml"; do
  xmllint --noout "$P/$part"
done
rm -f "$OUT"
ITEMS="[Content_Types].xml _rels word"
[ -d "$P/docProps" ] && ITEMS="$ITEMS docProps"
(cd "$P" && zip -q -X -r "$OUT" $ITEMS)
echo "$OUT"
