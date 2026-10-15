#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see docs/DOCX.md).
# TTAB notice of opposition (ttab-notice-of-opposition.typ): EB Garamond 12 pt; the body double-spaced
# (24 pt exact pitch, the typst line pitch) with a half-inch first-line indent on every paragraph; headings
# bold and centered, in capitals (level 1 at 17 pt, level 2 at 14.5 pt: the typst default heading sizes), single-spaced; footnotes and block quotations single-spaced; US Letter with
# 1-inch margins; a centered arabic page number in the footer, from 1 (one section: no restart).
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
perl -0pi -e '
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />}s;
  s{<w:spacing w:after="200" />}{<w:spacing w:after="0" />}s;
  s{(<w:style [^>]*w:styleId="BodyText".*?)<w:pPr>\s*<w:spacing w:before="180" w:after="180" />\s*</w:pPr>}{$1<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>}s;
  s{(<w:style [^>]*w:styleId="BlockText".*?)<w:pPr>.*?</w:pPr>}{$1<w:pPr><w:spacing w:before="120" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" w:left="720" w:right="720" /></w:pPr>}s;
  s{(<w:style [^>]*w:styleId="Compact".*?)<w:pPr>.*?</w:pPr>}{$1<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr>}s;
  s{(<w:style [^>]*w:styleId="FootnoteText".*?)</w:style>}{$1<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>}s;
  for my $n (1..3) {
    my $ppr = qq{<w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr>};
    my $sz = $n == 1 ? 34 : ($n == 2 ? 29 : 24);
    my $rpr = qq{<w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="$sz" /><w:szCs w:val="$sz" /></w:rPr>};
    s{(<w:style [^>]*w:styleId="Heading$n".*?)<w:pPr>.*?</w:pPr>\s*<w:rPr>.*?</w:rPr>(\s*</w:style>)}{$1$ppr$rpr$2}s;
  }
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:pgNumType w:fmt="decimal" w:start="1" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
