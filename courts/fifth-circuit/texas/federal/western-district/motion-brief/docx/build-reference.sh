#!/bin/sh
# Builds docx/reference.docx for the txwd motion with brief from pandoc's default reference (docs/DOCX.md).
# Form (typst/txwd-motion-brief.typ, W.D. Tex. Local Rule CV-10(a)): EB Garamond 13 pt (vendored), exact 26 pt
# (double) line pitch for body text, exact 15.6 pt (single) for the caption, headings, block quotations,
# signature, certificate and footnotes; 0.5 in first-line indent; headings: level 1 centred bold, levels 2 and 3
# left bold; letter page with 1 in margins on all sides; centred PAGE number in the footer; table of contents
# entries with dot leaders (TOC1 to TOC3).
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
export FONT
cat > "$W/styles.pl" <<'PL'
use strict;
my $font = $ENV{FONT};
my $f = do { local $/; open my $h, '<', $ARGV[0] or die; <$h> };
# document defaults: EB Garamond 13 pt, no theme fonts
$f =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$font<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s or die "docDefaults";
my $rpr_black = qq{<w:rPr>$font<w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr>};
my $rpr_bold = qq{<w:rPr>$font<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr>};
my $dbl = '<w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/>';
my $sgl = '<w:spacing w:before="0" w:after="0" w:line="312" w:lineRule="exact"/>';
my %st = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$dbl<w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr>$rpr_black</w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>},
  Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312" w:after="312" w:line="312" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr>$rpr_bold</w:style>},
  Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312" w:after="312" w:line="312" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr>$rpr_bold</w:style>},
  Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312" w:after="312" w:line="312" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr>$rpr_bold</w:style>},
  Centered => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$sgl<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  Single => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$sgl<w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>},
  Sig => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Sig"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>},
  CertText => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertificateText"><w:name w:val="Certificate Text"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="312" w:after="312" w:line="312" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
  BreakStart => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BreakStart"><w:name w:val="Break Start"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$font<w:sz w:val="2"/><w:szCs w:val="2"/></w:rPr></w:style>},
  TOC1 => qq{<w:style w:type="paragraph" w:styleId="TOC1"><w:name w:val="toc 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="180" w:line="312" w:lineRule="exact"/><w:ind w:left="0" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr>$rpr_black</w:style>},
  TOC2 => qq{<w:style w:type="paragraph" w:styleId="TOC2"><w:name w:val="toc 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="180" w:line="312" w:lineRule="exact"/><w:ind w:left="432" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr>$rpr_black</w:style>},
  TOC3 => qq{<w:style w:type="paragraph" w:styleId="TOC3"><w:name w:val="toc 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="180" w:line="312" w:lineRule="exact"/><w:ind w:left="864" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr>$rpr_black</w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="156" w:line="312" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$font<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>},
  Footer => qq{<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr>$sgl<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>$rpr_black</w:style>},
);
for my $id (keys %st) { $f =~ s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{}s; }
my $add = join '', map { $st{$_} } sort keys %st;
$f =~ s{</w:styles>}{$add</w:styles>}s or die "styles";
open my $o, '>', $ARGV[0] or die; print $o $f; close $o;
PL
perl "$W/styles.pl" word/styles.xml

# footer: centred page number (PAGE field, cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdTxwdFooter" Target="footer1.xml"/></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' '[Content_Types].xml'

# body section: letter, 1 in margins on all sides, the footer
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdTxwdFooter"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
export SECT
perl -0pi -e 'BEGIN{$s=$ENV{SECT}} if (s{<w:sectPr\b.*?</w:sectPr>}{$s}s) {} else { s{</w:body>}{$s</w:body>} }' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: document.xml has no r namespace" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
