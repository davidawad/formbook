#!/bin/sh
# Builds docx/reference.docx for the nyeb motion with memorandum of law from pandoc's default reference.
# Mirrors typst/nyeb-motion-brief.typ: EB Garamond 12 pt; body on an exact 24 pt (double) pitch with a 0.5 in
# first-line indent; counsel block, caption and signature on an exact 13.8 pt pitch; letter paper, 1 in margins.
# Footer: the matter number at the left (text MATTERNUMBER, replaced by render.sh from the frontmatter) and the
# page number on the centre tab.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, xmllint; pkg.pl does the zip step)
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
perl "$HERE/pkg.pl" unpack "$W/ref.docx" "$W/pkg"

cat > "$W/styles-new.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="320" w:line="276" w:lineRule="exact"/><w:ind w:left="1440" w:right="1440" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="FirstParagraph"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="160" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="FirstParagraph"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="160" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="FirstParagraph"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="160" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleKeep"><w:name w:val="Single Keep"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Spacer"><w:name w:val="Spacer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SpacerShort"><w:name w:val="Spacer Short"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SpacerAfterTitle"><w:name w:val="Spacer After Title"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SpacerKeep"><w:name w:val="Spacer Keep"/><w:basedOn w:val="Spacer"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Bullet"><w:name w:val="Bullet"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1080"/></w:tabs><w:ind w:left="1080" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BulletKeep"><w:name w:val="Bullet Keep"/><w:basedOn w:val="Bullet"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
XML

cat > "$W/patch-styles.pl" <<'PERL'
use strict;
use warnings;
my ($styles_path, $new_path) = @ARGV;
my $new = do { local $/; open my $f, '<', $new_path or die "$new_path: $!\n"; <$f> };
my $xml = do { local $/; open my $f, '<', $styles_path or die "$styles_path: $!\n"; <$f> };
(my $defaults = $new) =~ s{^.*?(<w:docDefaults>.*?</w:docDefaults>).*$}{$1}s;
(my $styles = $new) =~ s{<w:docDefaults>.*?</w:docDefaults>}{}s;
$xml =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults in styles.xml\n";
while ($styles =~ /<w:style\b[^>]*w:styleId="([^"]+)"/g) {
    my $id = $1;
    $xml =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>[ \t\r\n]*}{}s;
}
$styles =~ s{\s+$}{};
$xml =~ s{</w:styles>}{$styles\n</w:styles>}s or die "no </w:styles>\n";
open my $out, '>', $styles_path or die "$styles_path: $!\n";
print {$out} $xml;
close $out;
PERL
perl "$W/patch-styles.pl" "$W/pkg/word/styles.xml" "$W/styles-new.xml"

# footer: matter number at the left (10 pt; MATTERNUMBER is replaced by render.sh), page number on the centre tab
cat > "$W/pkg/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:tabs><w:tab w:val="center" w:pos="4680"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t xml:space="preserve">MATTERNUMBER</w:t></w:r><w:r><w:tab/></w:r><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML

cat > "$W/sect.xml" <<'XML'
<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>
XML
cat > "$W/patch-parts.pl" <<'PERL'
use strict;
use warnings;
my ($pkg, $sect_path) = @ARGV;
my $sect = do { local $/; open my $f, '<', $sect_path or die "$sect_path: $!\n"; <$f> };
$sect =~ s/\s+$//;
my $edit = sub {
    my ($path, $re, $to) = @_;
    my $t = do { local $/; open my $f, '<', $path or die "$path: $!\n"; <$f> };
    $t =~ s{$re}{$to}s or die "$path: pattern not found\n";
    open my $o, '>', $path or die "$path: $!\n";
    print {$o} $t;
    close $o;
};
$edit->("$pkg/word/document.xml", qr{<w:sectPr>.*?</w:sectPr>}s, $sect);
$edit->("$pkg/word/_rels/document.xml.rels", qr{</Relationships>},
    '<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml"/></Relationships>');
$edit->("$pkg/[Content_Types].xml", qr{</Types>},
    '<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>');
PERL
perl "$W/patch-parts.pl" "$W/pkg" "$W/sect.xml"

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels "[Content_Types].xml"; do
    xmllint --noout "$W/pkg/$part"
done
mkdir -p "$(dirname "$OUT")"
rm -f "$OUT"
perl "$HERE/pkg.pl" pack "$W/pkg" "$OUT"
echo "$OUT"
