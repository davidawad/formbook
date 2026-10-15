#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see docs/DOCX.md). The court form is the one
# in typst/mnd-complaint.typ: 13-point EB Garamond throughout; letter paper, 1-inch margins; body double-spaced at
# 29.9 pt exact (the typst pitch, 2.3 em); half-inch first-line indent, justified; centred bold headings with one
# double line above; single-spaced footnotes and block text; page number centred in the bottom margin (LR 5.2(a)).
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/x"

# docDefaults: must come first in styles.xml (before latentStyles and the styles).
cat > "$T/docdefaults.frag" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="26" /><w:szCs w:val="26" /><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" /></w:pPr></w:pPrDefault></w:docDefaults>
XML

# Styles (twips: 20 per point; double = 598 exact, single = 299 exact). Custom style "Prayer Item" is used by ../mnd-complaint.lua.
cat > "$T/styles.frag" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:widowControl /><w:spacing w:before="0" w:after="0" w:line="598" w:lineRule="exact" /></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="598" w:lineRule="exact" /><w:ind w:firstLine="720" /><w:jc w:val="both" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="598" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="left" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerItem"><w:name w:val="Prayer Item" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:ind w:left="1440" w:hanging="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading1Char" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="86" w:after="86" w:line="598" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading2Char" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="86" w:after="86" w:line="598" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact" /><w:ind w:firstLine="0" w:left="720" w:right="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="99" /><w:unhideWhenUsed /><w:pPr><w:spacing w:before="0" w:after="60" w:line="299" w:lineRule="exact" /><w:jc w:val="both" /></w:pPr><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
XML

# Merge: replace the default docDefaults and the styles above by id; keep every other style (FootnoteReference, Hyperlink, ...).
cat > "$T/merge.pl" <<'PL'
my ($xml_path, $dd_path, $st_path) = @ARGV;
local $/;
open my $fh, '<', $xml_path or die "$xml_path: $!";
my $x = <$fh>;
close $fh;
open my $dh, '<', $dd_path or die "$dd_path: $!";
my $dd = <$dh>;
close $dh;
open my $sh, '<', $st_path or die "$st_path: $!";
my $st = <$sh>;
close $sh;
$x =~ s{<w:docDefaults>.*?</w:docDefaults>}{}s;
for my $id (qw(Normal BodyText FirstParagraph Compact NumberedParagraph PrayerItem Heading1 Heading2 BlockText FootnoteText)) {
  $x =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
}
$x =~ s{(<w:styles[^>]*>)}{$1$dd}s;
$x =~ s{(</w:styles>)}{$st$1}s;
print $x;
PL
perl "$T/merge.pl" "$W/word/styles.xml" "$T/docdefaults.frag" "$T/styles.frag" > "$T/styles.new"
mv "$T/styles.new" "$W/word/styles.xml"

# Section: letter paper, 1-inch margins, footer 0.5 inch from the edge, page-number footer (below).
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /></w:sectPr>}s' "$W/word/document.xml"
grep -q 'xmlns:r=' "$W/word/document.xml" || { echo "make-reference.sh: document.xml lacks the r namespace" >&2; exit 1; }
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" .)
echo "$OUT"
