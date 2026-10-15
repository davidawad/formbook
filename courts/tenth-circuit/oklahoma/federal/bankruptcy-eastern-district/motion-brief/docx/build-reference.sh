#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, to the form of typst/okeb-motion-brief.typ
# EB Garamond 12 pt everywhere (footnotes included), black, exact 27.6 pt double spacing, 0.5 in first-line indent,
# letter paper, 1 in margins, page number centered in the footer. Heading 1 is bold, centered capitals; headings
# 2 and 3 are bold at the margin (3 indented 0.5 in), as in the motion-brief typst form.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
unzip -q "$W/ref.docx" -d "$W/pkg"
cd "$W/pkg"
cat > "$W/style.pl" <<'PL'
use strict; use warnings;
my ($styles, $doc) = @ARGV;
sub slurp { my $f = shift; open my $h, '<:encoding(UTF-8)', $f or die "$f: $!\n"; local $/; my $c = <$h>; close $h; return $c }
sub spit { my ($f, $c) = @_; open my $h, '>:encoding(UTF-8)', $f or die "$f: $!\n"; print $h $c; close $h }
my $F = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $s = slurp($styles);
# one face, one size, black, everywhere (the theme fonts and colours of the default reference are dropped)
$s =~ s{<w:rFonts\s[^>]*?/>}{$F}sg;
$s =~ s{<w:sz\s+w:val="\d+"\s*/>}{<w:sz w:val="24"/>}g;
$s =~ s{<w:szCs\s+w:val="\d+"\s*/>}{<w:szCs w:val="24"/>}g;
$s =~ s{<w:color\s[^>]*?/>}{}sg;
my $sz = '<w:sz w:val="24"/><w:szCs w:val="24"/>';
my %def = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr>$F$sz</w:rPr></w:style>},
  BodyText => q{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>},
  Compact => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  Title => q{<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  Heading1 => q{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:caps/>$sz</w:rPr></w:style>},
  Heading2 => q{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/>$sz</w:rPr></w:style>},
  Heading3 => q{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/>$sz</w:rPr></w:style>},
  BlockText => q{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
  FootnoteText => q{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$sz</w:rPr></w:style>},
  Footer => q{<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr>$sz</w:rPr></w:style>},
  Centered => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  Single => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  PropertyList => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="PropertyList"><w:name w:val="Property List"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="120" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:firstLine="0"/></w:pPr></w:style>},
  Numbered => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Numbered"><w:name w:val="Numbered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>},
  SigBlock => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/></w:pPr></w:style>},
);
for my $id (sort keys %def) {
  if ($s =~ s{<w:style\s[^>]*?w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$def{$id}}s) { next }
  $s =~ s{</w:styles>}{$def{$id}</w:styles>} or die "no </w:styles>\n";
}
spit($styles, $s);
# body section: letter, 1 in margins, the page-number footer (footer1.xml, relationship rIdOkebFooter)
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdOkebFooter"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>';
my $d = slurp($doc);
if ($d =~ s{<w:sectPr\b.*?</w:sectPr>}{$sect}s) { } else { $d =~ s{</w:body>}{$sect</w:body>}s or die "no body\n" }
spit($doc, $d);
PL
perl "$W/style.pl" word/styles.xml word/document.xml
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdOkebFooter" Target="footer1.xml"/></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
