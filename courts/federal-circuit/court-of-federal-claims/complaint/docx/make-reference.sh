#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../docs/DOCX.md): EB Garamond 12 pt
# (RCFC 5.5(c)(2)); the body double-spaced at 27.6 pt exact (the typst pitch, 2 x 1.15 em) with a half-inch
# first-line indent, justified; headings single-spaced (exact 13.8 pt); footnotes and block quotations
# single-spaced, footnotes 12 pt; letter page with 1-inch margins (RCFC 5.5(c)(1)(A), (c)(3)); a centred
# arabic page-number footer on every page (RCFC 5.5(c)(6)).
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
export W
perl -0pi -e '
  my $f = qq{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />};
  my $defaults = qq{<w:docDefaults><w:rPrDefault><w:rPr>$f<w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>};
  s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s;
  # Replace a paragraph style by id (whole element), so no pandoc default survives.
  my %style = (
    BodyText => q{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact" /><w:ind w:firstLine="720" /><w:jc w:val="both" /></w:pPr></w:style>},
    FirstParagraph => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /></w:style>},
    Compact => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /></w:style>},
    BlockText => q{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="276" w:line="276" w:lineRule="exact" /><w:ind w:left="720" w:right="720" w:firstLine="0" /><w:jc w:val="left" /></w:pPr></w:style>},
    FootnoteText => q{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text" /><w:basedOn w:val="Normal" /><w:next w:val="FootnoteText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="120" w:line="276" w:lineRule="exact" /><w:jc w:val="both" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
    Heading1 => q{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="552" w:after="115" w:line="276" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
    Heading2 => q{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="552" w:after="115" w:line="276" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:caps /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
    Heading3 => q{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="552" w:after="115" w:line="276" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="left" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
  );
  for my $id (keys %style) {
    my $new = $style{$id};
    s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$new}s or die "no style $id\n";
  }
  # Styles this template adds: prayer items (the complaint lists, typst indents 0.58 in and 1.17 in), and single-spaced lines.
  my $extra = join("", map { qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$_->[0]"><w:name w:val="$_->[1]" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:ind w:left="$_->[2]" w:firstLine="0" /></w:pPr></w:style>} } ([ "PrayerItem", "Prayer Item", 840 ], [ "PrayerItem2", "Prayer Item 2", 1680 ]));
  $extra .= q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleLine"><w:name w:val="Single Line" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="left" /></w:pPr></w:style>};
  s{</w:styles>}{$extra</w:styles>}s;
' "$W/word/styles.xml"
# Section: letter, 1-inch margins, footer with the page number on every page.
# Order follows CT_SectPr: footerReference, footnotePr, pgSz, pgMar.
perl -0pi -e '
  s{<w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
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
