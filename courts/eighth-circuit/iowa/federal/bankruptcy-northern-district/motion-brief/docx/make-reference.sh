#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document, to match the typst template
# (../typst/ianb-motion-brief.typ): EB Garamond 13 pt; body double-spaced (24.05 pt exact) with a half-inch
# first-line indent; "#" headings centered and bold, "##" argument headings bold and left; footnotes 11 pt
# single-spaced; letter page with 1-inch margins; a centered "Page X of Y" footer at 10 pt. The caption,
# numbering, certificate and signature block are built by docx/ianb-motion-brief.lua, not here.
# Usage: sh docx/make-reference.sh [out.docx]
# Needs pandoc, perl, unzip, zip, xmllint (tools/bootstrap.sh and micromamba zip/unzip/libxml2 put them on PATH).
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

# Style fragments: every <w:style> here replaces the default of the same styleId (or is appended).
cat > "$T/styles-fragment.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond" /><w:sz w:val="26" /><w:szCs w:val="26" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal" /><w:qFormat /><w:pPr><w:widowControl /></w:pPr><w:rPr><w:color w:val="000000" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="156" w:line="481" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="481" w:lineRule="exact" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NumberedParagraph"><w:name w:val="Numbered Paragraph" /><w:basedOn w:val="BodyText" /><w:qFormat /><w:pPr><w:tabs><w:tab w:val="left" w:pos="1200" /></w:tabs><w:spacing w:before="0" w:after="156" w:line="481" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="182" w:line="481" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="156" w:line="481" w:lineRule="exact" /><w:ind w:firstLine="0" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:b /><w:bCs /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text" /><w:basedOn w:val="Normal" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="254" w:lineRule="exact" /></w:pPr><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr></w:style>
XML

# Footer: "Page X of Y", centered, 10 pt (typst: text(size: 10pt)).
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:t xml:space="preserve">Page </w:t></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:t xml:space="preserve"> of </w:t></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:instrText xml:space="preserve"> NUMPAGES </w:instrText></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML

cat > "$T/edit.pl" <<'PL'
# usage: perl edit.pl styles-fragment.xml word/styles.xml word/document.xml word/_rels/document.xml.rels "[Content_Types].xml"
use strict;
use warnings;
sub slurp { my ($f) = @_; local $/; open my $h, '<', $f or die "$f: $!"; my $s = <$h>; close $h; return $s }
sub spit { my ($f, $s) = @_; open my $h, '>', $f or die "$f: $!"; print $h $s; close $h }
my ($frag_f, $styles_f, $doc_f, $rels_f, $ct_f) = @ARGV;
my $frag = slurp($frag_f);
my $s = slurp($styles_f);
if ($frag =~ m{(<w:docDefaults>.*?</w:docDefaults>)}s) {
  my $dd = $1;
  $s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults in styles.xml";
}
while ($frag =~ m{(<w:style [^>]*w:styleId="([^"]+)".*?</w:style>)}sg) {
  my ($xml, $id) = ($1, $2);
  if ($s =~ m{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}s) {
    $s =~ s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$xml}s;
  } else {
    $s =~ s{</w:styles>}{$xml\n</w:styles>}s;
  }
}
spit($styles_f, $s);
my $d = slurp($doc_f);
my $sect = q{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:footnotePr><w:numRestart w:val="eachSect" /></w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:cols w:space="720" /></w:sectPr>};
$d =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s or die "no sectPr in document.xml";
spit($doc_f, $d);
my $r = slurp($rels_f);
$r =~ s{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s;
spit($rels_f, $r);
my $c = slurp($ct_f);
$c =~ s{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s;
spit($ct_f, $c);
PL

perl "$T/edit.pl" "$T/styles-fragment.xml" "$W/word/styles.xml" "$W/word/document.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q "$OUT" '[Content_Types].xml' && zip -X -q -r "$OUT" _rels word $(ls -d docProps 2>/dev/null))
echo "$OUT"
