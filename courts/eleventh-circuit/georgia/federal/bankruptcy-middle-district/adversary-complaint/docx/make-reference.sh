#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (docs/DOCX.md). The court's mandated form as
# this template sets it (../README.md, "Layout"): EB Garamond 13 pt; body double-spaced (24 pt exact) with a half-inch
# first-line indent; block quotations and footnotes single-spaced (footnotes 12 pt); headings single-spaced and bold;
# letter page with 1-inch margins; a centered page number in the footer on every page.
# The caption, the title, the wherefore paragraph, the signature blocks and the numbering of the paragraphs are
# written by docx/gamb.lua (they need Word paragraphs with their own indents and spacing).
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
# Document defaults: EB Garamond 13 pt, single-spaced, no space after (every style below sets its own spacing).
perl -0pi -e '
  my $f = $ENV{FONT};
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$f<w:sz w:val="26" /><w:szCs w:val="26" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>}s;
  my %style = (
    Normal => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr>},
    BodyText => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:left="0" w:firstLine="720" /><w:jc w:val="left" /></w:pPr>},
    FirstParagraph => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:left="0" w:firstLine="720" /><w:jc w:val="left" /></w:pPr>},
    BlockText => q{<w:pPr><w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:left="1080" w:right="1080" w:firstLine="0" /></w:pPr>},
    FootnoteText => q{<w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr>},
  );
  for my $id (keys %style) {
    my $body = $style{$id};
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="$id" /><w:basedOn w:val="Normal" /><w:qFormat />$body</w:style>}s;
  }
  # Headings: keep with the next paragraph; level 1 centered, bold; level 2 bold; level 3 bold italic (typst: heading show rules).
  for my $n (1..3) {
    my $jc = $n == 1 ? q{<w:jc w:val="center" />} : q{<w:jc w:val="left" />};
    my $ital = $n == 3 ? q{<w:i /><w:iCs />} : q{};
    my $new = qq{<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="0" w:firstLine="0" />$jc<w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr><w:rPr><w:b /><w:bCs />$ital<w:color w:val="000000" /></w:rPr></w:style>};
    s{<w:style [^>]*w:styleId="Heading$n".*?</w:style>}{$new}s;
  }
' "$W/word/styles.xml"
# Letter page, 1-inch margins, the page number in the footer (every section). Pandoc takes the sectPr of this file.
perl -0pi -e '
  s{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /></w:sectPr>}s;
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
