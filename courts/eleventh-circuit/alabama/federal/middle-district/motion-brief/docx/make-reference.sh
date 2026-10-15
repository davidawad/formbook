#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (docs/DOCX.md; typst: almd-motion-brief.typ).
# EB Garamond 14 pt everywhere; body lines double-spaced (32.2 pt exact) with a half-inch first-line indent and a
# 23.1 pt gap between paragraphs; headings and the single-spaced blocks at 16.1 pt exact; letter page with 1-inch
# margins; a centered page number in the footer. The caption, the signature block and the service note are written
# by docx/almd.lua as paragraphs and a borderless table with their own formatting. A block quotation is single-spaced
# (16.1 pt) with 12.6 pt between its paragraphs; its last paragraph ("Block Text Last") keeps the 23.1 pt gap.
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
export FONT
# Each style the court uses is replaced whole, so no inherited spacing from pandoc's defaults survives.
# Spacing in twentieths of a point: 322 = 16.1 pt (single), 644 = 32.2 pt (double), 462 = 23.1 pt (gap between blocks).
perl -0pi -e '
  my $f = $ENV{FONT};
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{$f}s;
  s{<w:sz w:val="24" />\s*<w:szCs w:val="24" />}{<w:sz w:val="28" /><w:szCs w:val="28" />}s;
  my $body = q{<w:pPr><w:spacing w:before="0" w:after="462" w:line="644" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>};
  my %style = (
    Normal => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr>},
    BodyText => $body,
    FirstParagraph => $body,
    Compact => $body,
    BlockText => q{<w:pPr><w:spacing w:before="0" w:after="252" w:line="322" w:lineRule="exact" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr>},
    FootnoteText => q{<w:pPr><w:spacing w:before="0" w:after="100" w:line="322" w:lineRule="exact" /></w:pPr><w:rPr><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr>},
  );
  for my $id (keys %style) {
    my $b = $style{$id};
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="$id" /><w:basedOn w:val="Normal" /><w:qFormat />$b</w:style>}s;
  }
  # the last paragraph of a block quotation: the gap after the quotation (almd.lua puts it in this style)
  my $last = q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BlockTextLast"><w:name w:val="Block Text Last" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="462" w:line="322" w:lineRule="exact" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr></w:style>};
  s{(</w:styles>)}{$last$1}s;
  # Headings: level 1 centered, levels 2 and 3 flush left with a hanging half inch (a wrapped "I." or "A." heading lines up);
  # all bold, black, single-spaced, kept with the next paragraph.
  for my $n (1..3) {
    my $jc = $n == 1 ? q{<w:jc w:val="center" />} : q{};
    my $ind = $n == 1 ? q{<w:ind w:firstLine="0" />} : q{<w:ind w:left="720" w:hanging="720" />};
    my $new = qq{<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="462" w:line="322" w:lineRule="exact" />$ind$jc<w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style>};
    s{<w:style [^>]*w:styleId="Heading$n".*?</w:style>}{$new}s;
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
