#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, to match typst/bia-brief-on-appeal.typ:
# Liberation Serif 12 pt (the vendored Times New Roman substitute, docs/FONTS.md), double spacing at an exact
# 28.75 pt pitch (measured from the typst render), 1 in margins on US letter, first-line indent 0.5 in on body
# paragraphs (not on the first paragraph after a heading, as typst does), single-spaced front matter, footnotes,
# a footer with the page number (centred) and the A-number (right) for the body section only.
# The section layout itself (cover, contents, body) is written by docx/bia.lua, not here.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl and xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q "$W/ref.docx"

# 1. style definitions. Each <w:style> here replaces the default with the same styleId (or is added);
#    the docDefaults block replaces pandoc's (its theme fonts would override the court face).
cat > "$W/styles-new.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="575" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:rFonts w:ascii="Liberation Serif" w:hAnsi="Liberation Serif" w:eastAsia="Liberation Serif" w:cs="Liberation Serif"/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="575" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="575" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="575" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="FirstParagraph"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="288" w:after="288" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="FirstParagraph"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="FirstParagraph"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="center" w:pos="4680"/><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverSmall"><w:name w:val="Cover Small"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC1"><w:name w:val="toc 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC2"><w:name w:val="toc 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="360" w:firstLine="0"/></w:pPr></w:style>
XML

# merge: replace the matching styles, add the new ones, keep the rest of pandoc's styles.xml
cat > "$W/merge.pl" <<'PERL'
use strict;
use warnings;
my ($styles_path, $new_path) = @ARGV;
local $/;
open(my $fh, '<', $styles_path) or die "cannot read $styles_path\n";
my $s = <$fh>;
close $fh;
open($fh, '<', $new_path) or die "cannot read $new_path\n";
my $new = <$fh>;
close $fh;
my @add;
while ($new =~ m{(<w:docDefaults>.*?</w:docDefaults>|<w:style [^>]*>.*?</w:style>)}gs) {
  my $b = $1;
  if ($b =~ /^<w:docDefaults>/) {
    $s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$b}s or die "no docDefaults in styles.xml\n";
    next;
  }
  my ($id) = $b =~ /w:styleId="([^"]+)"/;
  die "style without styleId\n" unless defined $id;
  $s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
  push @add, $b;
}
my $add = join("\n", @add) . "\n";
$s =~ s{</w:styles>}{$add</w:styles>} or die "no </w:styles> in styles.xml\n";
open(my $out, '>', $styles_path) or die "cannot write $styles_path\n";
print $out $s;
close $out;
PERL
perl "$W/merge.pl" word/styles.xml "$W/styles-new.xml"

# 2. footer: PAGE field (centred) and the A-number placeholder (right). render.sh fills the A-number from the
#    sample's frontmatter; the placeholder is the only text that differs between samples.
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:tab/></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r><w:r><w:tab/></w:r><w:r><w:t xml:space="preserve">A#__A_NUMBER__</w:t></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Id="rIdBiaFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'

# 3. the final section (the body after the cover and contents): US letter, 1 in margins, the footer,
#    page numbers restart at 1 on the Introduction (the cover and contents are the sections before it).
cat > "$W/sect.pl" <<'PERL'
use strict;
use warnings;
my $path = shift;
local $/;
open(my $fh, '<', $path) or die "cannot read $path\n";
my $x = <$fh>;
close $fh;
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdBiaFooter1"/>'
  . '<w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr>'
  . '<w:pgSz w:w="12240" w:h="15840"/>'
  . '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
  . '<w:pgNumType w:start="1"/></w:sectPr>';
$x =~ s{<w:sectPr>(?:(?!<w:sectPr>).)*?</w:sectPr>(\s*</w:body>)}{$sect$1}s or die "no body sectPr\n";
open(my $out, '>', $path) or die "cannot write $path\n";
print $out $x;
close $out;
PERL
perl "$W/sect.pl" word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done

# 4. zip into a temporary file, then move it into place (never a partial output)
rm -f "$OUT" "$W/out.docx"
zip -q -X -r "$W/out.docx" '[Content_Types].xml' _rels docProps word
mv "$W/out.docx" "$OUT"
echo "$OUT"
