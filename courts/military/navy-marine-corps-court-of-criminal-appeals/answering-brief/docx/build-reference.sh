#!/bin/sh
# Builds docx/reference.docx for the NMCCA brief (DOCX engine), from pandoc's default reference.docx.
# Mirrors typst/nmcca-*.typ: EB Garamond 14 pt everywhere (footnotes too, Rule 17(c)); body exact
# 33.6 pt (672 twips, double pitch); single 16.8 pt (336 twips) for headings, footnotes, block quotes;
# 0.5 in first-line indent; letter page, 1 in margins; centred PAGE field in the footer, decimal from 1.
# Explicit font names everywhere (no theme fonts), theme major/minor set to the same face.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
FONT="EB Garamond"
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q ../ref.docx

RF='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
# style fragments: "@@<styleId>" then the complete <w:style> element; "@@docDefaults" replaces the defaults
cat > "$W/styles.frag" <<FRAG
@@docDefaults
<w:docDefaults><w:rPrDefault><w:rPr>$RF<w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="336" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>
@@Normal
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@BodyText
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="672" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
@@FirstParagraph
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
@@Compact
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="672" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
@@BlockText
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="224" w:line="336" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
@@Heading1
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="392" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@Heading2
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="308" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:left="567" w:hanging="567"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@Heading3
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="308" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:left="567" w:hanging="567"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@Heading4
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading4Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="308" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:left="567" w:hanging="567"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@Heading5
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading5Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="308" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:left="567" w:hanging="567"/><w:jc w:val="left"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr>$RF<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@FootnoteText
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="100" w:line="336" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr><w:rPr>$RF<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
@@BodyKeep
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep With Next"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
@@BodyKeepFirst
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeepFirst"><w:name w:val="Body Keep With Next First"/><w:basedOn w:val="FirstParagraph"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
@@Footer
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="336" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr>$RF<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
FRAG


perl -e '
  my ($frag, $file) = @ARGV;
  local $/; open(my $f, "<", $frag) or die; my $fr = <$f>; close $f;
  open(my $s, "<", $file) or die; my $st = <$s>; close $s;
  my @p = split /^@@(\S+)\n/m, $fr;
  for (my $i = 1; $i < @p; $i += 2) {
    my ($id, $body) = ($p[$i], $p[$i+1]);
    if ($id eq "docDefaults") { $st =~ s{<w:docDefaults>.*?</w:docDefaults>}{$body}s or die "no docDefaults"; next; }
    $st =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s;
    $st =~ s{</w:styles>}{$body</w:styles>}s;
  }
  $st =~ s/ w:(ascii|hAnsi|eastAsia|cs)Theme="[^"]*"//g;
  open(my $o, ">", $file) or die; print $o $st; close $o;
' "$W/styles.frag" word/styles.xml

# theme: the major and minor faces are the court face
perl -0pi -e 's{(<a:(?:major|minor)Font>\s*<a:latin typeface=")[^"]*"}{$1EB Garamond"}gs' word/theme/theme1.xml

# footer: centred PAGE field (cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdNmccaFooter" Target="footer1.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'

# body section (the final sectPr; the cover and index sections are set by the Lua filter):
# letter, 1 in margins, the page-number footer, decimal numbering from 1, continuous footnotes
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdNmccaFooter"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/theme/theme1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
