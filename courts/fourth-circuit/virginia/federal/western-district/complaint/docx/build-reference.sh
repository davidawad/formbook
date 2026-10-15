#!/bin/sh
# Builds docx/reference.docx for the W.D. Va. complaint from pandoc's default reference (the form of
# typst/vawd-complaint.typ): EB Garamond 13 pt, double spacing (27.6 pt exact), 0.5 in first-line indent,
# letter page with 1 in margins, centered caps section headings, centered bold count headings, 11 pt
# single-spaced footnotes, and a centered PAGE number in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, xmllint; unzip and zip, or perl's
# IO::Uncompress::Unzip and IO::Compress::Zip, to unpack and pack the package)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
if command -v unzip > /dev/null 2>&1; then
  unzip -q "$W/ref.docx" -d "$W/pkg"
else
  cat > "$W/unzip.pl" <<'PERL'
use strict; use warnings;
use IO::Uncompress::Unzip qw($UnzipError);
use File::Path qw(make_path);
use File::Basename qw(dirname);
my ($zip, $dst) = @ARGV;
my $z = IO::Uncompress::Unzip->new($zip) or die "unzip: $UnzipError\n";
while (1) {
  my $name = $z->getHeaderInfo->{Name};
  if ($name !~ m{/$}) {
    my $p = "$dst/$name"; make_path(dirname($p));
    open my $fh, '>:raw', $p or die "open $p: $!\n"; my $buf;
    while (read($z, $buf, 65536)) { print $fh $buf } close $fh;
  }
  last unless $z->nextStream;
}
PERL
  perl "$W/unzip.pl" "$W/ref.docx" "$W/pkg"
fi
cd "$W/pkg"
# 1. fonts: every font declaration names EB Garamond (no theme fonts)
perl -0pi -e 's{<w:rFonts [^>]*/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>}g' word/styles.xml
# 2. document defaults: 13 pt (26 half-points)
perl -0pi -e 's{(<w:docDefaults>.*?</w:docDefaults>)}{ (my $x = $1) =~ s{<w:sz w:val="\d+"/>}{<w:sz w:val="26"/>}g; $x =~ s{<w:szCs w:val="\d+"/>}{<w:szCs w:val="26"/>}g; $x }se' word/styles.xml
# 3. the styles of the form: replace pandoc's definition of each style id listed in styles-new.xml, then
#    append the custom ones (absent from pandoc's reference)
cat > "$W/styles-new.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="276" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="276" w:after="276" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigIndent"><w:name w:val="SigIndent"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Hanging"><w:name w:val="Hanging"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1296" w:hanging="576"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Recipient"><w:name w:val="Recipient"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="GapHalf"><w:name w:val="GapHalf"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ParensMark"><w:name w:val="ParensMark"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
XML
perl -0pi -e '
  open my $fh, "<", "$ENV{W}/styles-new.xml" or die; local $/; my $new = <$fh>; close $fh;
  while ($new =~ m{(<w:style [^>]*w:styleId="([^"]+)".*?</w:style>)}sg) {
    my ($blk, $id) = ($1, $2);
    s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
    $add{$id} .= $blk;
  }
  my $all = join "", map { $add{$_} } sort keys %add;
  s{</w:styles>}{$all</w:styles>};
' word/styles.xml
# 4. footer with the page number (PAGE field, cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
grep -q 'footer1.xml' word/_rels/document.xml.rels || sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
grep -q 'footer1.xml' '[Content_Types].xml' || sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# 5. the section: letter, 1 in margins, footer with the page number (replaces pandoc's sectPr)
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rIdFtr1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
export SECT
perl -0pi -e 'my $s = $ENV{SECT}; if (s{<w:sectPr\b.*?</w:sectPr>}{$s}s) { } else { s{</w:body>}{$s</w:body>} }' word/document.xml
grep -q 'xmlns:r=' word/document.xml || echo "warning: no r namespace on document root" >&2
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
if command -v zip > /dev/null 2>&1; then
  zip -q -X "$OUT" '[Content_Types].xml'
  zip -q -X -r "$OUT" _rels docProps word
else
  cat > "$W/zip.pl" <<'PERL'
use strict; use warnings;
use IO::Compress::Zip qw($ZipError);
use File::Find;
my ($out, $dir) = @ARGV;
my @all; find({ no_chdir => 1, wanted => sub { push @all, $_ if -f $_ } }, $dir);
my %rel = map { (my $r = $_) =~ s{^\Q$dir\E/}{}; ($_ => $r) } @all;
my @ordered = ((grep { $rel{$_} eq '[Content_Types].xml' } @all), (grep { $rel{$_} ne '[Content_Types].xml' } sort @all));
my $z; my $first = 1;
for my $p (@ordered) {
  open my $fh, q(<:raw), $p or die "$p: $!\n";
  if ($first) { $z = IO::Compress::Zip->new($out, Name => $rel{$p}) or die "zip: $ZipError\n"; $first = 0 }
  else { $z->newStream(Name => $rel{$p}) or die "zip: $ZipError\n" }
  my $b; while (read($fh, $b, 65536)) { $z->print($b) } close $fh;
}
$z->close or die "zip close\n";
PERL
  perl "$W/zip.pl" "$OUT" "$W/pkg"
fi
echo "$OUT"
