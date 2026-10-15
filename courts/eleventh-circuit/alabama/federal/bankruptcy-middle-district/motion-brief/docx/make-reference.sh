#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document, to the form of the typst template
# (typst/almb-motion-brief.typ): EB Garamond 13 pt everywhere; the body double-spaced (24 pt exact)
# with a half-inch first-line indent; headings centered and bold (caps for level 1), single-spaced; block
# quotations and footnotes single-spaced; letter page with 1-inch margins; a centered "-N-" page number in the
# footer at 11 pt. The caption, the consent block and the signature block are written by docx/almb-motion-brief.lua.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />'
DEFAULTS='<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="26" /><w:szCs w:val="26" /><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>'
# Each style the court uses is replaced whole (no inherited spacing from pandoc's defaults survives).
NEWSTYLES='<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style><w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="Prayer"><w:name w:val="Prayer" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /></w:pPr></w:style><w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="36" /><w:szCs w:val="36" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style><w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="99" /><w:unhideWhenUsed /><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr></w:style>'
export FONT DEFAULTS NEWSTYLES
perl -0pi -e '
  my $f = $ENV{FONT};
  my $d = $ENV{DEFAULTS};
  my $n = $ENV{NEWSTYLES};
  s{<w:docDefaults>.*?</w:docDefaults>}{$d}s;
  s{<w:rFonts [^>]*/>}{$f}g;
  my %drop = map { $_ => 1 } qw(BodyText FirstParagraph BlockText Heading1 Heading2 Heading3 FootnoteText Prayer);
  s{<w:style [^>]*w:styleId="([^"]+)".*?</w:style>}{ $drop{$1} ? "" : $& }gse;
  s{</w:styles>}{$n</w:styles>}s;
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t xml:space="preserve">-</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t xml:space="preserve">-</w:t></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
