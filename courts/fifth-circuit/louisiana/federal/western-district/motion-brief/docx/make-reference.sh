#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (docs/DOCX.md). Form, from the typst
# template (typst/lawd-motion-brief.typ) and LR 7.1, 7.8, 10.1 (double spaced, paginated, 8 1/2 x 11):
#   EB Garamond 12 pt; body double spaced at an exact 24 pt pitch with a half-inch first-line indent; level 1
#   headings bold centered capitals, level 2 bold at the margin, level 3 bold italic; caption, title, signature
#   block and tables single spaced (exact 13.8 pt), the TOA entries double spaced with dot leaders; letter page,
#   1-inch margins; a centered page number. The page-number format and restart come from the sections that
#   render.sh writes around the front matter (roman) and the body (arabic from 1): see render.sh.
# Usage: sh docx/make-reference.sh [out.docx]    (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/w"
(cd "$T/w" && unzip -q "$T/default.docx")
W="$T/w"
F='w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"'

# Replace a style block by styleId, or append it when the reference has none.
put_style() {
  id=$1
  export NEWXML="$2"
  if grep -q "w:styleId=\"$id\"" "$W/word/styles.xml"; then
    perl -0pi -e 's{<w:style [^>]*w:styleId="'"$id"'".*?</w:style>}{$ENV{NEWXML}}s' "$W/word/styles.xml"
  else
    perl -0pi -e 's{</w:styles>}{$ENV{NEWXML}</w:styles>}s' "$W/word/styles.xml"
  fi
}

perl -0pi -e 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts '"$F"' /><w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="480" w:lineRule="exact" /></w:pPr></w:pPrDefault></w:docDefaults>}s' "$W/word/styles.xml"

BLACK='<w:color w:val="000000" />'
DOUBLE='<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />'
SINGLE='<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact" />'
put_style Normal "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\"><w:name w:val=\"Normal\" /><w:qFormat /><w:pPr>$DOUBLE</w:pPr><w:rPr>$BLACK</w:rPr></w:style>"
put_style BodyText "<w:style w:type=\"paragraph\" w:styleId=\"BodyText\"><w:name w:val=\"Body Text\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr>$DOUBLE<w:ind w:firstLine=\"720\" /><w:jc w:val=\"left\" /></w:pPr></w:style>"
put_style FirstParagraph "<w:style w:type=\"paragraph\" w:styleId=\"FirstParagraph\"><w:name w:val=\"First Paragraph\" /><w:basedOn w:val=\"BodyText\" /><w:next w:val=\"BodyText\" /><w:qFormat /><w:pPr>$DOUBLE<w:ind w:firstLine=\"720\" /></w:pPr></w:style>"
put_style Compact "<w:style w:type=\"paragraph\" w:styleId=\"Compact\"><w:name w:val=\"Compact\" /><w:basedOn w:val=\"BodyText\" /><w:qFormat /><w:pPr>$DOUBLE<w:ind w:firstLine=\"0\" /></w:pPr></w:style>"
for n in 1 2 3; do
  case $n in
    1) ppr='<w:jc w:val="center" />'; rpr='<w:caps />' ;;
    2) ppr='<w:jc w:val="left" />'; rpr='' ;;
    3) ppr='<w:jc w:val="left" />'; rpr='<w:i />' ;;
  esac
  put_style "Heading$n" "<w:style w:type=\"paragraph\" w:styleId=\"Heading$n\"><w:name w:val=\"heading $n\" /><w:basedOn w:val=\"Normal\" /><w:next w:val=\"BodyText\" /><w:uiPriority w:val=\"9\" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before=\"480\" w:after=\"0\" w:line=\"480\" w:lineRule=\"exact\" /><w:ind w:firstLine=\"0\" />$ppr<w:outlineLvl w:val=\"$((n - 1))\" /></w:pPr><w:rPr><w:rFonts $F /><w:b /><w:bCs />$rpr$BLACK<w:sz w:val=\"24\" /><w:szCs w:val=\"24\" /></w:rPr></w:style>"
done
put_style FootnoteText "<w:style w:type=\"paragraph\" w:styleId=\"FootnoteText\"><w:name w:val=\"footnote text\" /><w:basedOn w:val=\"Normal\" /><w:pPr>$SINGLE<w:ind w:firstLine=\"0\" /></w:pPr><w:rPr><w:sz w:val=\"24\" /><w:szCs w:val=\"24\" /></w:rPr></w:style>"
put_style BlockText "<w:style w:type=\"paragraph\" w:styleId=\"BlockText\"><w:name w:val=\"Block Text\" /><w:basedOn w:val=\"Normal\" /><w:pPr><w:spacing w:before=\"0\" w:after=\"240\" w:line=\"276\" w:lineRule=\"exact\" /><w:ind w:left=\"720\" w:right=\"720\" w:firstLine=\"0\" /></w:pPr></w:style>"
put_style SingleSpaced "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"SingleSpaced\"><w:name w:val=\"Single Spaced\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr>$SINGLE<w:ind w:firstLine=\"0\" /></w:pPr></w:style>"
put_style SingleCentered "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"SingleCentered\"><w:name w:val=\"Single Centered\" /><w:basedOn w:val=\"SingleSpaced\" /><w:qFormat /><w:pPr><w:jc w:val=\"center\" /></w:pPr></w:style>"
put_style SignatureBlock "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"SignatureBlock\"><w:name w:val=\"Signature Block\" /><w:basedOn w:val=\"SingleSpaced\" /><w:qFormat /><w:pPr><w:ind w:left=\"4680\" w:firstLine=\"0\" /></w:pPr></w:style>"
put_style LetteredItem "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"LetteredItem\"><w:name w:val=\"Lettered Item\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr><w:tabs><w:tab w:val=\"left\" w:pos=\"1440\" /></w:tabs><w:ind w:left=\"1440\" w:hanging=\"720\" /></w:pPr></w:style>"
put_style CenteredBold "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"CenteredBold\"><w:name w:val=\"Centered Bold\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before=\"480\" w:after=\"0\" w:line=\"480\" w:lineRule=\"exact\" /><w:ind w:firstLine=\"0\" /><w:jc w:val=\"center\" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style>"
for n in 1 2 3; do
  put_style "TOC$n" "<w:style w:type=\"paragraph\" w:styleId=\"TOC$n\"><w:name w:val=\"toc $n\" /><w:basedOn w:val=\"Normal\" /><w:next w:val=\"Normal\" /><w:uiPriority w:val=\"39\" /><w:unhideWhenUsed /><w:pPr><w:tabs><w:tab w:val=\"right\" w:leader=\"dot\" w:pos=\"9350\" /></w:tabs><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"480\" w:lineRule=\"exact\" /><w:ind w:left=\"$((n * 720 - 720))\" w:right=\"720\" w:firstLine=\"0\" /></w:pPr></w:style>"
done
put_style TOAEntry "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"TOAEntry\"><w:name w:val=\"TOA Entry\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr><w:tabs><w:tab w:val=\"right\" w:leader=\"dot\" w:pos=\"9360\" /></w:tabs><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"480\" w:lineRule=\"exact\" /><w:ind w:left=\"720\" w:hanging=\"720\" w:firstLine=\"0\" /></w:pPr></w:style>"
put_style TOACategory "<w:style w:type=\"paragraph\" w:customStyle=\"1\" w:styleId=\"TOACategory\"><w:name w:val=\"TOA Category\" /><w:basedOn w:val=\"Normal\" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"480\" w:lineRule=\"exact\" /><w:ind w:firstLine=\"0\" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style>"

# The final section (the body, arabic numbers from 1). render.sh gives the front matter its own section.
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:pgNumType w:fmt="decimal" w:start="1" /></w:sectPr>}s' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
# The table of contents is a field; Word updates it on open (the field is also marked dirty in the sample).
perl -0pi -e 's{(<w:footnotePr>)}{<w:updateFields w:val="true" />$1}s' "$W/word/settings.xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/settings.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
