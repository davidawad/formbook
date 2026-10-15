#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document for the flnd motion (typst template:
# typst/flnd-motion-brief.typ; rules and layout: ../README.md). Usage: sh docx/make-reference.sh [out.docx]
# Needs pandoc, perl, unzip, zip and xmllint on PATH. The result is committed; rerun only when the layout changes.
#   * EB Garamond 14 pt everywhere (Loc. R. 5.1(C)); black text.
#   * body and headings on an exact 32.2 pt pitch (double spacing, measured on the filed exemplar; the typst template).
#   * single-spaced cover lines on an exact 16 pt pitch; no paragraph spacing in the body.
#   * level 1 headings centered in capitals; level 2 bold, left, with a hanging indent of 0.5 inch (A., B.); level 3 bold.
#   * US Letter, 1-inch margins, a centered page-number footer (PAGE field) at 0.5 inch.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

cat > "$T/defaults.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:color w:val="000000" /><w:kern w:val="2" /><w:sz w:val="28" /><w:szCs w:val="28" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>
XML

# Styles replaced by name (pandoc's theme-coloured defaults are dropped), then the cover styles appended.
cat > "$T/styles.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:widowControl w:val="0" /><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading1Char" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="256" w:after="128" w:line="644" w:lineRule="exact" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="39" /><w:szCs w:val="39" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading2Char" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="62" w:line="768" w:lineRule="exact" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="34" /><w:szCs w:val="34" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading3Char" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="144" w:after="288" w:line="644" w:lineRule="exact" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="99" /><w:unhideWhenUsed /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="Caption Line" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionVersus"><w:name w:val="Caption Versus" /><w:basedOn w:val="CaptionLine" /><w:qFormat /><w:pPr><w:spacing w:before="320" w:after="320" w:line="320" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaseTitle"><w:name w:val="Case Title" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLine"><w:name w:val="Signature Line" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SpacerPitch"><w:name w:val="Spacer Pitch" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SpacerSingle"><w:name w:val="Spacer Single" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SpacerSigGap"><w:name w:val="Spacer Signature Gap" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="182" w:lineRule="exact" /></w:pPr></w:style>
XML

cat > "$T/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML

pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/x"

DEFAULTS="$T/defaults.xml" STYLES="$T/styles.xml" perl -0pi -e '
  BEGIN {
    local $/;
    open my $d, "<", $ENV{DEFAULTS} or die; $defaults = <$d>; close $d;
    open my $s, "<", $ENV{STYLES} or die; $styles = <$s>; close $s;
    chomp $defaults; chomp $styles;
  }
  s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s;
  for my $id (qw(BodyText Compact Heading1 Heading2 Heading3 FootnoteText)) {
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{}s;
  }
  s{</w:styles>}{$styles\n</w:styles>}s;
' "$W/word/styles.xml"

perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
cp "$T/footer1.xml" "$W/word/footer1.xml"
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
