#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (pandoc 3.6.x), for the bap6 opening brief.
# Mandated form (typst/bap6-opening-brief.typ, calibrated there): EB Garamond 14 pt (FRBP 8015(a)(5)(A)),
# double spacing = exact 36.4 pt body line pitch (FRBP 8015(a)(4)), single = exact 18.2 pt for headings,
# block quotations, cover, TOC and TOA, 1 in margins on letter paper, first-line indent 0.5 in,
# a PAGE field centered in the footer. Sections: cover (no footer), front matter (lower roman),
# brief (arabic from 1). The section breaks themselves are written by docx/bap6-brief.lua.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

# 1. styles: drop the pandoc styles this template replaces, then append the bap6 styles
cat > "$W/new-styles.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="364" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="728" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="280" w:after="392" w:line="364" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="448" w:after="336" w:line="510" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="39"/><w:szCs w:val="39"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="336" w:after="280" w:line="437" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="308" w:after="280" w:line="364" w:lineRule="exact"/><w:ind w:left="720" w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="280" w:after="280" w:line="364" w:lineRule="exact"/><w:ind w:left="1440" w:firstLine="0"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="364" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverGap"><w:name w:val="CoverGap"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="392"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverTitle"><w:name w:val="CoverTitle"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="392"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverBottom"><w:name w:val="CoverBottom"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="1440" w:after="252"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="364" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontHeading"><w:name w:val="FrontHeading"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="448" w:after="336" w:line="510" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="39"/><w:szCs w:val="39"/></w:rPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontHeadingBreak"><w:name w:val="FrontHeadingBreak"/><w:basedOn w:val="FrontHeading"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="OutlineBreak"><w:name w:val="OutlineBreak"/><w:basedOn w:val="Heading1"/><w:qFormat/><w:pPr><w:pageBreakBefore/><w:outlineLvl w:val="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="AuthorityKind"><w:name w:val="AuthorityKind"/><w:basedOn w:val="Normal"/><w:next w:val="AuthorityLine"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="336" w:after="280" w:line="364" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="AuthorityLine"><w:name w:val="AuthorityLine"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="280"/><w:ind w:left="720" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4680" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureLead"><w:name w:val="SignatureLead"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:spacing w:before="448" w:after="336"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureDate"><w:name w:val="SignatureDate"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:spacing w:before="224"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC1"><w:name w:val="toc 1"/><w:basedOn w:val="Single"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:spacing w:after="200"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC2"><w:name w:val="toc 2"/><w:basedOn w:val="Single"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:spacing w:after="200"/><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC3"><w:name w:val="toc 3"/><w:basedOn w:val="Single"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:spacing w:after="200"/><w:ind w:left="1440" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC4"><w:name w:val="toc 4"/><w:basedOn w:val="Single"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:spacing w:after="200"/><w:ind w:left="2160" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
XML
perl -0pi -e '
  my @ids = qw(Normal BodyText FirstParagraph Compact BlockText Heading1 Heading2 Heading3 Heading4 FootnoteText Title Subtitle Author Date Abstract);
  for my $id (@ids) { s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s }
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="364" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  open my $f, "<", "$ENV{W}/new-styles.xml" or die; local $/; my $new = <$f>; close $f;
  s{</w:styles>}{$new</w:styles>}s;
' word/styles.xml
for id in Normal BodyText FirstParagraph Heading1 Heading2 Heading3 Heading4 Footer Centered Single TOC1; do
  n=$(grep -o "w:styleId=\"$id\"" word/styles.xml | wc -l)
  [ "$n" -eq 1 ] || { echo "build-reference.sh: style $id appears $n times" >&2; exit 1; }
done

# 2. footer: a PAGE field, centered, with the cached result 1 (pages are numbered by the viewer)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdBapFooter1" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# 3. the final section (the brief, arabic from 1) replaces pandoc's sectPr; footer reference as above
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdBapFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>}s' word/document.xml

# 4. settings: Word updates the TOC and TOA fields on open (their page numbers need a layout pass)
perl -0pi -e 's{<w:footnotePr>}{<w:updateFields w:val="true"/><w:footnotePr>}' word/settings.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/settings.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$part"
done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X -r "$OUT" '[Content_Types].xml' _rels docProps word
echo "$OUT"
