#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../docs/DOCX.md):
# TeX Gyre Schola 14 pt (the face the typst template names); body double-spaced at the typst pitch (32.3 pt exact; single-spaced parts 20 pt exact),
# first-line indent 0.5 in; headings, block quotations, footnotes single-spaced; Letter with 1-inch margins;
# footer with a PAGE field (the cover has no footer). Usage: sh docx/make-reference.sh [out.docx]
# Needs: pandoc, perl, unzip, zip, xmllint.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
W="$T/w"
mkdir "$W"
(cd "$W" && unzip -q "$T/default.docx")
FONT='<w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" w:eastAsia="TeX Gyre Schola" w:cs="TeX Gyre Schola" />'
SZ='<w:sz w:val="28" /><w:szCs w:val="28" />'
perl -0pi -e '
  my $font = q{'"$FONT"'}; my $sz = q{'"$SZ"'};
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$font$sz<w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>}s;
  sub setstyle {
    my ($id, $body) = @_;
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{$body}s or die "no style $id";
  }
  setstyle("Normal", qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="646" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr><w:rPr>$font$sz</w:rPr></w:style>});
  setstyle("BodyText", qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="646" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>});
  setstyle("FirstParagraph", qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:ind w:firstLine="0" /></w:pPr></w:style>});
  setstyle("Compact", qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="400" w:lineRule="exact" /></w:pPr></w:style>});
  setstyle("Heading1", qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="400" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr>$font<w:b /><w:bCs /><w:caps /><w:color w:val="000000" />$sz</w:rPr></w:style>});
  setstyle("Heading2", qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="160" w:line="400" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr>$font<w:b /><w:bCs /><w:color w:val="000000" />$sz</w:rPr></w:style>});
  setstyle("Heading3", qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="200" w:after="160" w:line="400" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr>$font<w:b /><w:bCs /><w:i /><w:iCs /><w:color w:val="000000" />$sz</w:rPr></w:style>});
  setstyle("BlockText", qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="400" w:lineRule="exact" /><w:ind w:firstLine="0" w:left="720" w:right="720" /></w:pPr></w:style>});
  setstyle("FootnoteText", qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="9" /><w:pPr><w:spacing w:before="0" w:after="120" w:line="400" w:lineRule="exact" /><w:ind w:firstLine="0" /></w:pPr><w:rPr>$font$sz</w:rPr></w:style>});
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooterPage" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:pgNumType w:fmt="decimal" w:start="1" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer-page.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" /><w:sz w:val="28" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" /><w:sz w:val="28" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" /><w:sz w:val="28" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" /><w:sz w:val="28" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="TeX Gyre Schola" w:hAnsi="TeX Gyre Schola" /><w:sz w:val="28" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooterPage" Target="footer-page.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer-page.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
# footnotes number through the document: the filter's raw section breaks must not restart them (pandoc's
# reference restarts them each section)
perl -0pi -e 's{<w:numRestart w:val="eachSect" />}{<w:numRestart w:val="continuous" />}g' "$W/word/document.xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer-page.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
