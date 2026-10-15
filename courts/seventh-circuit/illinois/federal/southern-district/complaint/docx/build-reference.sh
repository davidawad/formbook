#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx, for the ilsd complaint and motion (DOCX engine).
# Body: EB Garamond 12 pt, exact 24 pt (double) line pitch, 0.5 in first-line indent, 1 in margins, letter.
# Footnotes: 12 pt, single. Headings: 12 pt bold, black. Custom styles for the cover, caption, signature,
# prayer items and certificate (Centered, Single, CaptionLine, ...). Footer: centered PAGE field.
# Mirrors the typst template (typst/ilsd-*.typ). Usage: sh docx/build-reference.sh <absolute out.docx>
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/ref.docx"

cat > "$W/fix.pl" <<'PERL'
use strict;
use warnings;

sub slurp { my ($f) = @_; local $/; open my $h, '<:raw', $f or die "$f: $!"; my $s = <$h>; close $h; return $s }
sub spit { my ($f, $s) = @_; open my $h, '>:raw', $f or die "$f: $!"; print $h $s; close $h; return }

my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $RPR  = "<w:rPr>$FONT<w:color w:val=\"000000\"/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>";
my $BOLD = "<w:rPr>$FONT<w:b/><w:bCs/><w:color w:val=\"000000\"/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>";
my $SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>';
my $EXACT24 = '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>';
my $EXACT14 = '<w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/>';

# one paragraph style: id, display name, basedOn, pPr children (schema order), rPr, customStyle flag
sub ps {
  my ($id, $name, $based, $ppr, $rpr, $custom) = @_;
  my $c = $custom ? ' w:customStyle="1"' : '';
  my $b = defined $based ? "<w:basedOn w:val=\"$based\"/>" : '';
  my $p = defined $ppr ? "<w:pPr>$ppr</w:pPr>" : '';
  my $r = defined $rpr ? $rpr : '';
  return "<w:style w:type=\"paragraph\"$c w:styleId=\"$id\"><w:name w:val=\"$name\"/>$b<w:qFormat/>$p$r</w:style>";
}

my @styles = (
  ['Normal', '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/>'
    . "<w:pPr>$SINGLE</w:pPr>$RPR</w:style>"],
  # body paragraphs: double spaced, first-line indent 0.5 in (numbered paragraphs, body text, certificate text)
  ['BodyText', ps('BodyText', 'Body Text', 'Normal',
    '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/>', undef, 0)],
  ['FirstParagraph', ps('FirstParagraph', 'First Paragraph', 'BodyText',
    '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/>', undef, 1)],
  # headings: 12 pt bold black; level 2 centered (complaint); outline levels kept for navigation
  ['Heading1', '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/>'
    . '<w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'
    . '<w:spacing w:before="360" w:after="120" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>'
    . "<w:outlineLvl w:val=\"0\"/></w:pPr>$BOLD</w:style>"],
  ['Heading2', '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/>'
    . '<w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'
    . '<w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>'
    . "<w:outlineLvl w:val=\"1\"/></w:pPr>$BOLD</w:style>"],
  ['Heading3', '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/>'
    . '<w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>'
    . '<w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/>'
    . "<w:outlineLvl w:val=\"2\"/></w:pPr>$BOLD</w:style>"],
  ['FootnoteText', '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/>'
    . '<w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/>'
    . "<w:ind w:firstLine=\"0\"/></w:pPr><w:rPr>$FONT<w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr></w:style>"],
  ['Footer', '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/>'
    . "<w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/><w:jc w:val=\"center\"/></w:pPr>$RPR</w:style>"],
  # custom styles (front matter, caption, signature, prayer items, certificate)
  ['Centered', ps('Centered', 'Centered', 'Normal', "$SINGLE<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/>", undef, 1)],
  ['Single', ps('Single', 'Single', 'Normal', "$SINGLE<w:ind w:firstLine=\"0\"/>", undef, 1)],
  ['CaptionLine', ps('CaptionLine', 'CaptionLine', 'Normal', "$EXACT14<w:ind w:firstLine=\"0\"/>", undef, 1)],
  ['CaptionCenter', ps('CaptionCenter', 'CaptionCenter', 'CaptionLine', "$EXACT14<w:ind w:firstLine=\"0\"/><w:jc w:val=\"center\"/>", undef, 1)],
  ['CaptionIndent', ps('CaptionIndent', 'CaptionIndent', 'CaptionLine', "$EXACT14<w:ind w:left=\"2016\" w:firstLine=\"0\"/>", undef, 1)],
  ['CaptionRight', ps('CaptionRight', 'CaptionRight', 'CaptionLine', "$EXACT14<w:ind w:left=\"360\" w:firstLine=\"0\"/>", undef, 1)],
  ['Gap24', ps('Gap24', 'Gap24', 'Normal', "$EXACT24<w:ind w:firstLine=\"0\"/>", undef, 1)],
  ['SigIndent', ps('SigIndent', 'SigIndent', 'Single', '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/>', undef, 1)],
  ['SigAfterGap', ps('SigAfterGap', 'SigAfterGap', 'SigIndent', '<w:keepNext/><w:spacing w:before="144" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/>', undef, 1)],
  ['SigIndent30', ps('SigIndent30', 'SigIndent30', 'Single', '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4320" w:firstLine="0"/>', undef, 1)],
  ['SigAfterGap30', ps('SigAfterGap30', 'SigAfterGap30', 'SigIndent30', '<w:keepNext/><w:spacing w:before="144" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4320" w:firstLine="0"/>', undef, 1)],
  ['PrayerItem', ps('PrayerItem', 'PrayerItem', 'BodyText', '<w:spacing w:before="120" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/>', undef, 1)],
  ['HeadingHang', ps('HeadingHang', 'HeadingHang', 'Normal', '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/>', $BOLD, 1)],
  ['HeadingHang3', ps('HeadingHang3', 'HeadingHang3', 'Normal', '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:hanging="720"/>', $BOLD, 1)],
  ['MotionH1', ps('MotionH1', 'MotionH1', 'Normal', '<w:keepNext/><w:keepLines/><w:spacing w:before="360" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>', $BOLD, 1)],
  ['TitleBlock', ps('TitleBlock', 'TitleBlock', 'Normal', "$SINGLE<w:ind w:left=\"936\" w:right=\"936\" w:firstLine=\"0\"/><w:jc w:val=\"center\"/>", $BOLD, 1)],
  ['Recipient', ps('Recipient', 'Recipient', 'Single', '<w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:firstLine="0"/>', undef, 1)],
  ['DateLine', ps('DateLine', 'DateLine', 'Single', '<w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>', undef, 1)],
);

my $S = slurp('word/styles.xml');
sub set_style {
  my ($id, $xml) = @_;
  return if $S =~ s{<w:style\b[^>]*\bw:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$xml}s;
  $S =~ s{</w:styles>}{$xml</w:styles>} or die "no </w:styles>";
  return;
}
for my $pair (@styles) { set_style($pair->[0], $pair->[1]) }
my $DD = "<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/>"
  . '<w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>'
  . "<w:pPrDefault><w:pPr>$SINGLE</w:pPr></w:pPrDefault></w:docDefaults>";
$S =~ s{<w:docDefaults>.*?</w:docDefaults>}{$DD}s or die "no docDefaults";
spit('word/styles.xml', $S);

# section: letter, 1 in margins, footer with the page number (footer1.xml, rId100)
my $D = slurp('word/document.xml');
my $SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/>'
  . '<w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr>'
  . '<w:pgSz w:w="12240" w:h="15840"/>'
  . '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
$D =~ s{<w:sectPr>.*?</w:sectPr>}{$SECT}s or die "no sectPr";
spit('word/document.xml', $D);

spit('word/footer1.xml', '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  . '<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
  . 'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
  . '<w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr>'
  . '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  . '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  . '</w:p></w:ftr>');

my $R = slurp('word/_rels/document.xml.rels');
$R =~ s{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>}
  or die "no Relationships";
spit('word/_rels/document.xml.rels', $R);

my $T = slurp('[Content_Types].xml');
$T =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}
  or die "no Types";
spit('[Content_Types].xml', $T);
PERL

perl "$W/fix.pl"
for p in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$p"
done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
