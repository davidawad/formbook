#!/bin/sh
# Builds docx/reference.docx for the uscgcoca opening brief (and the answering brief, same form) from pandoc's
# default reference.docx. Matches typst/uscgcoca-*.typ as measured on the typst render (see README "## Engines"):
#   EB Garamond 12 pt; body lines at an exact 23.4 pt pitch (the typst body leading, double-spaced look);
#   single-spaced blocks (counsel, signature, proceeding) at 15.6 pt; letter, 1 in margins; centered PAGE field.
# Fonts are named explicitly in the styles and in the theme (no *Theme attributes), so the body embeds EB Garamond.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# paragraph styles (each replaces pandoc's style of the same styleId; the rest of pandoc's styles are kept)
cat > "$W/styles-new.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="468" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="468" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="468" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="314" w:after="330" w:line="312" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="640" w:after="542" w:line="312" w:lineRule="exact"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="34" w:after="0" w:line="336" w:lineRule="exact"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="34" w:after="0" w:line="336" w:lineRule="exact"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="468" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Header"><w:name w:val="header"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="468" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="CaptionLine"/><w:basedOn w:val="Centered"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredSingle"><w:name w:val="CenteredSingle"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertTitle"><w:name w:val="CertTitle"/><w:basedOn w:val="Centered"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:pageBreakBefore/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="SignatureBlock"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/><w:ind w:left="0" w:right="4752" w:firstLine="0"/></w:pPr></w:style>
XML
# docDefaults: the court font, 12 pt, no paragraph spacing
cat > "$W/docdefaults.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>
XML
# footer: centered PAGE field (cached result 1), 12 pt
F='<w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/></w:rPr>'
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r>$F<w:fldChar w:fldCharType="begin"/></w:r><w:r>$F<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>$F<w:fldChar w:fldCharType="separate"/></w:r><w:r>$F<w:t>1</w:t></w:r><w:r>$F<w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML

# styles.xml: docDefaults, the paragraph styles above, every theme font made explicit
cat > "$W/merge.pl" <<'PERL'
use strict; use warnings;
my $w = shift;
sub slurp { my $f = shift; open my $h, "<", $f or die "$f: $!\n"; local $/; my $t = <$h>; close $h; return $t }
my $s = slurp("word/styles.xml");
my $new = slurp("$w/styles-new.xml");
my $dd = slurp("$w/docdefaults.xml");
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults\n";
while ($new =~ /(<w:style [^>]*>.*?<\/w:style>)/gs) {
  my $b = $1;
  my ($id) = $b =~ /w:styleId="([^"]+)"/;
  $s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s;
  $s =~ s{</w:styles>}{$b\n</w:styles>}s;
}
$s =~ s{<w:rFonts [^>]*/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>}g;
$s =~ s{<w:color w:val="[0-9A-Fa-f]{6}"[^>]*/>}{<w:color w:val="000000"/>}g;
open my $o, ">", "word/styles.xml" or die "word/styles.xml: $!\n"; print $o $s; close $o;
PERL
perl "$W/merge.pl" "$W"

# theme: the major and minor fonts are the court font (pandoc's default is Aptos)
perl -0pi -e 's{(<a:majorFont>\s*<a:latin typeface=")[^"]*"( panose="[^"]*")?}{$1EB Garamond"}s; s{(<a:minorFont>\s*<a:latin typeface=")[^"]*"( panose="[^"]*")?}{$1EB Garamond"}s' word/theme/theme1.xml

# section: letter, 1 in margins, the page-number footer (replaces pandoc's sectPr, keeps its footnote setting)
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' word/document.xml
grep -q 'r:id="rId100"' word/document.xml || { echo "build-reference.sh: sectPr not written" >&2; exit 1; }
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml word/theme/theme1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
