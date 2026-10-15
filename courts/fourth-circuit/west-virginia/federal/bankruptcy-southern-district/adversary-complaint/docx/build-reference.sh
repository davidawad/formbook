#!/bin/sh
# Builds docx/reference.docx for the wvsb adversary complaint from pandoc's default reference.docx.
# The mandated form is the one typst/wvsb-adversary-complaint.typ encodes (FRBP 7001, 7010, 9004): EB Garamond
# 13 pt; body double-spaced at an exact 24 pt pitch with a 0.5 in first-line indent; caption, counsel blocks,
# footnotes and headings single-spaced at an exact 17 pt pitch; letter paper; 1 in margins; page number
# centered in the footer at 11 pt.
# Usage: sh docx/build-reference.sh <out.docx>
# Needs on PATH: pandoc, unzip, xmllint, ziptool (libzip). The package is rebuilt from the same parts each run.
# Scratch files go to a mktemp directory only; nothing is written in the working directory.
set -eu
OUT=$1
RF='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
export RF
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
unzip -q "$W/ref.docx" -d "$W/pkg"
P="$W/pkg"

# 1. the styles this template uses, written in full (pandoc's defaults use theme fonts and blue headings)
cat > "$W/styles-add.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="340" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="340" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="240" w:line="340" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="340" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="340" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="340" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="340" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr>$RF<w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr><w:tblPr><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleKeep"><w:name w:val="SingleKeep"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLeft"><w:name w:val="CaptionLeft"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:pBdr><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr><w:ind w:right="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionEnd"><w:name w:val="CaptionEnd"/><w:basedOn w:val="CaptionLeft"/><w:qFormat/><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionIndent12"><w:name w:val="CaptionIndent12"/><w:basedOn w:val="CaptionLeft"/><w:qFormat/><w:pPr><w:ind w:left="1728" w:right="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionIndent18"><w:name w:val="CaptionIndent18"/><w:basedOn w:val="CaptionLeft"/><w:qFormat/><w:pPr><w:ind w:left="2592" w:right="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionGap"><w:name w:val="CaptionGap"/><w:basedOn w:val="CaptionLeft"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="BodyKeep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRight"><w:name w:val="CaptionRight"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap6"><w:name w:val="Gap6"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="120" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap12"><w:name w:val="Gap12"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapKeep12"><w:name w:val="GapKeep12"/><w:basedOn w:val="Gap12"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapKeep24"><w:name w:val="GapKeep24"/><w:basedOn w:val="Gap24"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap24"><w:name w:val="Gap24"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="DocTitle"><w:name w:val="DocTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="SingleKeep"/><w:qFormat/></w:style>
XML

# 2. drop pandoc's versions of the styles above, then insert ours
ADD="$W/styles-add.xml" perl -0pi -e '
  BEGIN { local $/; open my $f, "<", $ENV{ADD} or die "no styles-add: $!"; $add = <$f>; close $f }
  my %drop = map { $_ => 1 } qw(Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 Heading4
    Heading1Char Title Subtitle Author Date BlockText FootnoteText Footer Table);
  s{<w:style [^>]*?w:styleId="([^"]+)"[^>]*>.*?</w:style>\s*}{ $drop{$1} ? "" : $& }gse;
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$ENV{RF}<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  s{</w:styles>}{$add</w:styles>}s;
' "$P/word/styles.xml"

# 3. footer with the page number (PAGE field, cached result 1), relationship and content type
cat > "$P/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>}' "$P/word/_rels/document.xml.rels"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$P/[Content_Types].xml"

# 4. the body section: letter, 1 in margins, footer with the page number (replaces pandoc's sectPr)
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>}s' "$P/word/document.xml"

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels; do
  xmllint --noout "$P/$part"
done

case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
rm -f "$OUT"
# ziptool adds each part by name; [Content_Types].xml first
cd "$P"
ziptool -n "$OUT" add '[Content_Types].xml' "$(cat '[Content_Types].xml')"
find _rels docProps word -type f | sort | while IFS= read -r f; do
  ziptool "$OUT" add "$f" "$(cat "$f")"
done
unzip -tq "$OUT" > /dev/null
echo "$OUT"
