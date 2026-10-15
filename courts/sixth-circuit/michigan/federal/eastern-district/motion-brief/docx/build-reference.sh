#!/bin/sh
# Builds docx/reference.docx for the E.D. Mich. motion to dismiss with the brief (docs/DOCX.md).
# Form (mirrors typst/mied-motion-brief.typ): US Letter, 1 in margins on all sides (LR 5.1(a)(2)); EB Garamond
# 14 pt (LR 5.1(a)(3); the vendored family, fonts/eb-garamond); body text exactly 644 twips (32.2 pt = 2.3 em, the
# typst double pitch) with a 0.5 in first-line indent; headings, block quotations, captions, authorities, contents
# and signature blocks single spaced; 12 pt centered page number in the footer.
# Sections (the page-number formats of the typst template) are written by the filter (mied-motion-brief.lua) as
# raw sectPr blocks that name footers by placeholder (r:id="FOOTER_PAGE" / "FOOTER_BLANK"); docx/render.sh maps
# the placeholders to the relationship ids pandoc gives the footer parts. Footer parts: footer1 = page number,
# footer2 = empty (the brief cover, unnumbered).
# Usage: sh docx/build-reference.sh <absolute out.docx>   (needs pandoc, unzip, zip, perl and xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# Styles, one w:style element each, replaced by styleId (or added). Order inside pPr/rPr follows the schema.
cat > "$W/styles.frag" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="140" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="CourtTitle"/><w:basedOn w:val="Centered"/><w:qFormat/><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionTitle"><w:name w:val="CaptionTitle"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCell"><w:name w:val="CaptionCell"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="140" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontHeading"><w:name w:val="FrontHeading"/><w:basedOn w:val="Centered"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="644" w:after="644" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertHeading"><w:name w:val="CertHeading"/><w:basedOn w:val="FrontHeading"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FrontSubhead"><w:name w:val="FrontSubhead"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="644" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Authority"><w:name w:val="Authority"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Issue"><w:name w:val="Issue"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:ind w:left="720" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCTitle"><w:name w:val="TOCTitle"/><w:basedOn w:val="FrontHeading"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC1"><w:name w:val="toc 1"/><w:basedOn w:val="Single"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC2"><w:name w:val="toc 2"/><w:basedOn w:val="TOC1"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:ind w:left="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="TOC3"><w:name w:val="toc 3"/><w:basedOn w:val="TOC1"/><w:next w:val="Normal"/><w:uiPriority w:val="39"/><w:unhideWhenUsed/><w:pPr><w:ind w:left="1440"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4608" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigTop"><w:name w:val="SigTop"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:spacing w:before="644" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLast"><w:name w:val="SigLast"/><w:basedOn w:val="Signature"/><w:qFormat/><w:pPr><w:keepNext w:val="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="DatedLine"><w:name w:val="DatedLine"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="644" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
XML

# docDefaults: EB Garamond 14 pt, single spacing. The final section (body and certificate): letter, 1 in margins,
# footer1 (page number), arabic numbering restarting at 1.
cat > "$W/fix.pl" <<'PERL'
use strict; use warnings;
my ($dir, $frag) = @ARGV;
sub slurp { my $f = shift; open my $h, '<:encoding(UTF-8)', $f or die "$f: $!"; local $/; my $s = <$h>; close $h; $s }
sub spew { my ($f, $s) = @_; open my $h, '>:encoding(UTF-8)', $f or die "$f: $!"; print $h $s; close $h }
my $st = slurp("$dir/word/styles.xml");
my $new = slurp($frag);
my $dd = <<'DD';
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
DD
$st =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults";
for my $s ($new =~ m{(<w:style .*?</w:style>)}gs) {
  my ($id) = $s =~ m{w:styleId="([^"]+)"};
  $st =~ s{<w:style [^>]*?w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s;
  $st =~ s{</w:styles>}{$s\n</w:styles>}s;
}
spew("$dir/word/styles.xml", $st);
my $footer = <<'FTR';
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
FTR
spew("$dir/word/footer1.xml", $footer);
my $blank = <<'FTR';
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr></w:p></w:ftr>
FTR
spew("$dir/word/footer2.xml", $blank);
my $rels = slurp("$dir/word/_rels/document.xml.rels");
$rels =~ s{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId101" Target="footer2.xml" /></Relationships>} or die "rels";
spew("$dir/word/_rels/document.xml.rels", $rels);
my $ct = slurp("$dir/[Content_Types].xml");
$ct =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>} or die "ct";
spew("$dir/[Content_Types].xml", $ct);
my $doc = slurp("$dir/word/document.xml");
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>';
$doc =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s or die "no sectPr";
spew("$dir/word/document.xml", $doc);
# Word asks to update fields on open, so the contents gets its page numbers (docs/DOCX.md, "Table of contents").
my $set = slurp("$dir/word/settings.xml");
if ($set !~ m{updateFields}) {
  # schema order: updateFields follows savePreviewPicture and precedes footnotePr (or the next element)
  $set =~ s{(<w:(?:hdrShapeDefaults|footnotePr|endnotePr|compat|docVars|rsids|m:mathPr|themeFontLang|clrSchemeMapping|decimalSymbol|listSeparator)[ >/])}{<w:updateFields w:val="true"/>$1} or die "settings";
  spew("$dir/word/settings.xml", $set);
}
PERL
perl "$W/fix.pl" "$W/pkg" "$W/styles.frag"
for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml word/settings.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
cd "$W/pkg" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
