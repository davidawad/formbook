#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the BAP 8th Cir. brief (FRBP 8015).
# Body: EB Garamond 14 pt (FRBP 8015(a)(5)(A)), exact 31 pt line pitch (double spacing, FRBP 8015(a)(4)),
# first-line indent 0.5 in, widow control, 1 in margins on US Letter. Footnotes and block quotations are
# single-spaced at 14 pt. Every font name is explicit (no theme fonts), so LibreOffice and Word both use EB Garamond.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
FONT="EB Garamond"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q ../ref.docx
F="<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\"/>"

# ---- the styles this template sets (pandoc's own copies are replaced) ----
{
cat <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>$F<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="629" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="629" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="629" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="280" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="140" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="FootnoteReference"><w:name w:val="footnote reference"/><w:rPr><w:vertAlign w:val="superscript"/></w:rPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
XML
# cover and front matter (single spaced, centered or indented)
cat <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverCenter"><w:name w:val="Cover Center"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverLeft"><w:name w:val="Cover Left"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverIndent"><w:name w:val="Cover Indent"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverGap"><w:name w:val="Cover Gap"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="200" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="DoubleRule"><w:name w:val="Double Rule"/><w:basedOn w:val="Normal"/><w:pPr><w:pBdr><w:bottom w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="8"/><w:szCs w:val="8"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ShortRule"><w:name w:val="Short Rule"/><w:basedOn w:val="Normal"/><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="3240" w:right="3240" w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="8"/><w:szCs w:val="8"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Indented"><w:name w:val="Indented"/><w:basedOn w:val="Normal"/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="140" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BulletItem"><w:name w:val="Bullet Item"/><w:basedOn w:val="Normal"/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="360"/></w:tabs><w:spacing w:before="0" w:after="140" w:line="240" w:lineRule="auto"/><w:ind w:left="360" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertBox"><w:name w:val="Certificate Box"/><w:basedOn w:val="Normal"/><w:pPr><w:keepLines/><w:spacing w:before="160" w:after="160" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontHeading"><w:name w:val="Front Heading"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="308" w:line="320" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SectionHeading"><w:name w:val="Section Heading"/><w:basedOn w:val="FrontHeading"/><w:next w:val="BodyText"/><w:pPr><w:spacing w:before="420" w:after="120" w:line="320" w:lineRule="exact"/><w:outlineLvl w:val="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SectionHeadingTop"><w:name w:val="Section Heading Top"/><w:basedOn w:val="SectionHeading"/><w:next w:val="BodyText"/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:outlineLvl w:val="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PointHeading"><w:name w:val="Point Heading"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="336" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:smallCaps/></w:rPr></w:style>
XML
# sub-headings: label at the hanging position, text one half inch further in (typst's label-indent)
for spec in "Sub2:1440:1" "Sub3:2160:2" "Sub4:2880:3" "Sub5:3600:4" "ArgSub3:1440:2" "ArgSub4:2160:3" "ArgSub5:2880:4"; do
  id=${spec%%:*}; rest=${spec#*:}; left=${rest%%:*}; lvl=${rest#*:}
  it=""; if [ "$lvl" -ge 3 ]; then it="<w:i/><w:iCs/>"; fi
  echo "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"$id\"><w:name w:val=\"$id\"/><w:basedOn w:val=\"Normal\"/><w:next w:val=\"BodyText\"/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val=\"left\" w:pos=\"$left\"/></w:tabs><w:spacing w:before=\"220\" w:after=\"180\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"$left\" w:hanging=\"720\" w:firstLine=\"0\"/><w:jc w:val=\"left\"/><w:outlineLvl w:val=\"$lvl\"/></w:pPr><w:rPr><w:b/><w:bCs/>$it</w:rPr></w:style>"
done
# table of contents lines: the same positions as the headings, dot leader to the right margin
for spec in "TOCArg:720:720" "TOC2:1440:720" "TOC3:2160:720" "TOC4:2880:720" "TOC5:3600:720" "TOC1:0:0"; do
  id=${spec%%:*}; rest=${spec#*:}; left=${rest%%:*}; hang=${rest#*:}
  echo "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"$id\"><w:name w:val=\"$id\"/><w:basedOn w:val=\"Normal\"/><w:pPr><w:keepLines/><w:tabs><w:tab w:val=\"left\" w:pos=\"$left\"/><w:tab w:val=\"right\" w:leader=\"dot\" w:pos=\"9360\"/></w:tabs><w:spacing w:before=\"140\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:ind w:left=\"$left\" w:right=\"720\" w:hanging=\"$hang\"/><w:jc w:val=\"left\"/></w:pPr></w:style>"
done
cat <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PageLabel"><w:name w:val="Page Label"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigGap"><w:name w:val="Signature Gap"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAGroup"><w:name w:val="TOA Group"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="280" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAEntry"><w:name w:val="TOA Entry"/><w:basedOn w:val="Normal"/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="140" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="504" w:right="720" w:hanging="504"/><w:jc w:val="left"/></w:pPr></w:style>
XML
} > "$W/new-styles.xml"

# replace same-id styles, then insert the new ones before </w:styles>
BAPNEW="$W/new-styles.xml"; export BAPNEW
perl -0pi -e '
  my $new = do { local $/; open my $f, "<", $ENV{BAPNEW} or die "new-styles: $!"; <$f> };
  my @blocks = ($new =~ /(<w:style [^>]*>.*?<\/w:style>)/gs);
  for my $b (@blocks) {
    my ($id) = $b =~ /w:styleId="([^"]+)"/;
    s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
  }
  s{</w:styles>}{join("\n", @blocks) . "\n</w:styles>"}e;
  # document defaults: EB Garamond 14 pt, widow control, single spacing
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>'"$F"'<w:kern w:val="2"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  s{ w:(ascii|hAnsi|eastAsia|cs)Theme="[^"]*"}{}g;
' word/styles.xml
xmllint --noout word/styles.xml

# theme: the major and minor latin faces are the court font as well
perl -0pi -e 's{(<a:(major|minor)Font>\s*<a:latin typeface=")[^"]*(")}{$1'"$FONT"'$3}g' word/theme/theme1.xml
xmllint --noout word/theme/theme1.xml

# ---- footer: centered PAGE field (the front matter and the body each restart their own count, in the sections) ----
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
xmllint --noout word/footer1.xml
perl -pi -e 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdBapFooter" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
perl -pi -e 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# ---- body section (the last section of the document): letter, 1 in margins, the footer ----
perl -0pi -e 's{<w:sectPr\b[^>]*>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdBapFooter"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>}s' word/document.xml
xmllint --noout word/document.xml

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
