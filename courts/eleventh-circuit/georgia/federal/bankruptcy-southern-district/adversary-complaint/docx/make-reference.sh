#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (docs/DOCX.md), to match typst/gasb-adversary-complaint.typ:
#   EB Garamond 13 pt everywhere (type-size); body double-spaced (exact 24 pt, line-pitch) with a half-inch first-line
#   indent (para-indent); numbered paragraphs (the author's "1.", "2.", ... ) with the number at half an inch and the
#   text hanging at 0.75 in; headings bold, centered, single-spaced, 12 pt above and below; footnotes 13 pt, single-spaced;
#   letter page with 1-inch margins; a centered page number (11 pt) in the footer of every page, the caption page included.
# The caption, the title and the signature block are written by docx/gasb-adversary-complaint.lua as paragraphs and
# tables with their own formatting.
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
# Each style the court uses is replaced whole, so no inherited spacing or theme font from pandoc's defaults survives.
perl -0pi -e '
  my $f = $ENV{FONT};
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{$f}s;
  s{<w:sz w:val="24" />\s*<w:szCs w:val="24" />}{<w:sz w:val="26" /><w:szCs w:val="26" />}s;
  s{<w:spacing w:after="200" />}{<w:spacing w:after="0" />}s;
  my %style = (
    Normal => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr>},
    BodyText => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    FirstParagraph => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    Compact => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    BlockText => q{<w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="720" w:right="720" w:firstLine="0" /></w:pPr>},
    FootnoteText => q{<w:pPr><w:spacing w:before="0" w:after="104" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr>},
  );
  for my $id (keys %style) {
    my $body = $style{$id};
    my $based = $id eq "Normal" ? "" : qq{<w:basedOn w:val="Normal" />};
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="$id" />$based<w:qFormat />$body</w:style>}s;
  }
  # Headings: bold, centered, single-spaced, 12 pt above and below (typst: show heading). Levels 1-9 alike.
  for my $n (1..9) {
    my $new = qq{<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>};
    s{<w:style [^>]*w:styleId="Heading$n".*?</w:style>}{$new}s;
  }
  # The numbered paragraph (complaint paragraphs; the list numbers are typed by the author and carried as text).
  my $np = q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:left="1080" w:hanging="360" /></w:pPr></w:style>};
  s{(</w:styles>)}{$np$1}s;
' "$W/word/styles.xml"
# Page: letter, 1-inch margins; the footer reference is added to the section below.
perl -0pi -e '
  # schema order in w:sectPr: footerReference, footnotePr, pgSz, pgMar
  s{<w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
