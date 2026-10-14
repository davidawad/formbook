#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../docs/DOCX.md): EB Garamond 14 pt; the
# body double-spaced (31.4 pt exact) with a half-inch first-line indent; headings single-spaced, bold, black (level 1
# centered capitals); footnotes and block quotations single-spaced; letter page with 1-inch margins; a centered
# page-number footer. Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
SRC="$T/x"
W="$T/w"
mkdir "$W"
cp -R "$SRC/." "$W/"
perl -0pi -e '
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />}s;
  s{<w:sz w:val="24" />\s*<w:szCs w:val="24" />}{<w:sz w:val="28" /><w:szCs w:val="28" />}s;
  s{<w:spacing w:after="200" />}{<w:spacing w:after="0" />}s;
  s{(<w:style [^>]*w:styleId="BodyText".*?)<w:pPr>\s*<w:spacing w:before="180" w:after="180" />\s*</w:pPr>}{$1<w:pPr><w:spacing w:before="0" w:after="0" w:line="629" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>}s;
  s{(<w:style [^>]*w:styleId="BlockText".*?)<w:pPr>.*?</w:pPr>}{$1<w:pPr><w:spacing w:before="0" w:after="180" w:line="399" w:lineRule="exact" /><w:ind w:firstLine="0" w:left="720" w:right="720" /></w:pPr>}s;
  s{(<w:style [^>]*w:styleId="FootnoteText".*?)</w:style>}{$1<w:pPr><w:spacing w:before="0" w:after="120" w:line="399" w:lineRule="exact" /></w:pPr><w:rPr><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style>}s;
  for my $n (1..5) {
    my $jc = $n == 1 ? q{<w:jc w:val="center" />} : q{};
    my $caps = $n == 1 ? q{<w:caps />} : q{};
    my $ital = $n >= 4 ? q{<w:i />} : q{};
    my $ppr = qq{<w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="120" w:line="399" w:lineRule="exact" /><w:ind w:firstLine="0" />$jc<w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr>};
    my $rpr = qq{<w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs />$caps$ital<w:color w:val="000000" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr>};
    s{(<w:style [^>]*w:styleId="Heading$n".*?)<w:pPr>.*?</w:pPr>\s*<w:rPr>.*?</w:rPr>(\s*</w:style>)}{$1$ppr$rpr$2}s;
  }
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0" />}s;
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
