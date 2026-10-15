#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../docs/DOCX.md): EB Garamond 12 pt
# everywhere; the body double-spaced (24 pt exact) with a half-inch first-line indent; block quotations and
# footnotes (10 pt) single-spaced; headings single-spaced, bold, black; a "Lettered" paragraph style for lettered
# and roman items (left indent 0.5 in, double-spaced) and "Numbered" paragraphs (number at 0.5 in, text at 0.8 in); letter page with 1-inch margins; a centered page number in
# the footer. The caption, the signature and the certificates are written by docx/<name>.lua as paragraphs with
# their own formatting.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
# H2_JC: alignment of level-2 headings (center for the complaint, left for the motion; see the court's typst/).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
H2_JC=${H2_JC:-center}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />'
export FONT H2_JC
perl -0pi -e '
  my $f = $ENV{FONT};
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{$f}s;
  my %style = (
    Normal => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr>},
    BodyText => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    FirstParagraph => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    Compact => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /></w:pPr>},
    BlockText => q{<w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr>},
    FootnoteText => q{<w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr>},
    Lettered => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:left="720" w:firstLine="0" /></w:pPr>},
    Numbered => q{<w:pPr><w:tabs><w:tab w:val="left" w:pos="1152" /></w:tabs><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
  );
  for my $id (keys %style) {
    my $body = $style{$id};
    my $new = qq{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="$id" /><w:basedOn w:val="Normal" /><w:qFormat />$body</w:style>};
    if (s{<w:style [^>]*w:styleId="$id".*?</w:style>}{$new}s) { } else { s{(</w:styles>)}{$new$1}s }
  }
  for my $n (1..3) {
    my $jc = $n == 1 ? q{<w:jc w:val="center" />} : $n == 2 ? qq{<w:jc w:val="$ENV{H2_JC}" />} : q{};
    my $caps = $n == 1 ? q{<w:caps />} : q{};
    my $ital = $n == 3 ? q{<w:i />} : q{};
    my $new = qq{<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="480" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" />$jc<w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr><w:rPr><w:b /><w:bCs />$ital$caps<w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>};
    s{<w:style [^>]*w:styleId="Heading$n".*?</w:style>}{$new}s;
  }
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
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
