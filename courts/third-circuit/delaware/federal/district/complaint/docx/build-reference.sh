#!/bin/sh
# D. Del. complaint, DOCX engine: builds docx/reference.docx from pandoc's default reference.docx.
# The parameters trace to typst/ded-complaint.typ: EB Garamond 13 pt (LR 5.1.1(a): at least 12 point for
# all printed matter), a 27 pt exact line pitch (double spacing, as the template), 1 in margins, a 0.5 in
# first-line indent, single-spaced footnotes at 13 pt, and a centred page number at 13 pt in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc and perl with IO::Compress::Zip and IO::Uncompress::Unzip)
set -eu
FONT="EB Garamond"
SIZE=26          # half-points: 13 pt
FOOT_SIZE=26     # footnote text and footer: 13 pt
PITCH=540        # twips: 27 pt exact line pitch
INDENT=720       # first-line indent: 0.5 in
MARGIN=1440      # 1 in
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# zip helpers (perl core modules; the box has no unzip or zip binary)
cat > "$W/unpack.pl" <<'PL'
use strict; use IO::Uncompress::Unzip qw($UnzipError);
my ($src, $dir) = @ARGV;
my $z = IO::Uncompress::Unzip->new($src) or die "unzip: $UnzipError";
my $st = 1;
while ($st > 0) {
  my $name = $z->getHeaderInfo->{Name};
  if (length($name) && $name !~ m{/$}) {
    my $path = "$dir/$name"; (my $d = $path) =~ s{/[^/]*$}{};
    system("mkdir", "-p", $d) == 0 or die "mkdir $d";
    open(my $fh, ">", $path) or die "write $path: $!"; binmode $fh;
    my $buf; while ($z->read($buf) > 0) { print $fh $buf } close $fh;
  }
  $st = $z->nextStream;
}
PL
cat > "$W/pack.pl" <<'PL'
use strict; use IO::Compress::Zip qw($ZipError);
my ($out, $dir, @names) = @ARGV;
my $first = shift @names;
my $z = IO::Compress::Zip->new($out, Name => $first, Time => 0) or die "zip: $ZipError";
my @all = ($first, @names);
for my $i (0 .. $#all) {
  my $n = $all[$i];
  open(my $fh, "<", "$dir/$n") or die "open $n: $!"; binmode $fh; local $/; my $data = <$fh>; close $fh;
  $z->newStream(Name => $n, Time => 0) or die "zip: $ZipError" if $i > 0;
  $z->print($data);
}
$z->close or die "zip close: $ZipError";
PL

pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
perl "$W/unpack.pl" "$W/ref.docx" "$W/pkg"
cd "$W/pkg"

# styles: replace the pandoc styles this template uses, add the custom ones (single, centred, front matter)
cat > "$W/styles.pl" <<'PL'
use strict;
my ($font, $size, $foot, $pitch, $indent, $margin) = @ARGV;
local $/; open(my $fh, "<", "word/styles.xml") or die; my $s = <$fh>; close $fh;
my $fonts = qq{<w:rFonts w:ascii="$font" w:hAnsi="$font" w:eastAsia="$font" w:cs="$font"/>};
my $defaults = qq{<w:docDefaults><w:rPrDefault><w:rPr>$fonts<w:sz w:val="$size"/><w:szCs w:val="$size"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>};
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults";
my %style = (
  Normal => [ 'paragraph', 'Normal', '', qq{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr>}, '' ],
  BodyText => [ 'paragraph', 'Body Text', 'Normal', qq{<w:pPr><w:spacing w:before="0" w:after="0" w:line="$pitch" w:lineRule="exact"/><w:ind w:firstLine="$indent"/></w:pPr>}, '' ],
  FirstParagraph => [ 'paragraph', 'First Paragraph', 'BodyText', '', '' ],
  Compact => [ 'paragraph', 'Compact', 'BodyText', qq{<w:pPr><w:spacing w:before="0" w:after="0" w:line="$pitch" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr>}, '' ],
  BlockText => [ 'paragraph', 'Block Text', 'Normal', qq{<w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="$indent" w:right="$indent" w:firstLine="0"/></w:pPr>}, '' ],
  Heading1 => [ 'paragraph', 'heading 1', 'Normal', qq{<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="270" w:after="270" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr>}, '<w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/></w:rPr>' ],
  Heading2 => [ 'paragraph', 'heading 2', 'Normal', qq{<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="270" w:after="270" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr>}, '<w:rPr><w:b/><w:bCs/><w:color w:val="000000"/></w:rPr>' ],
  Heading3 => [ 'paragraph', 'heading 3', 'Normal', qq{<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="270" w:after="270" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr>}, '<w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/></w:rPr>' ],
  FootnoteText => [ 'paragraph', 'footnote text', 'Normal', qq{<w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr>}, qq{<w:rPr><w:sz w:val="$foot"/><w:szCs w:val="$foot"/></w:rPr>} ],
  ListLetter => [ 'paragraph', 'List Letter', 'BodyText', qq{<w:pPr><w:spacing w:before="0" w:after="0" w:line="$pitch" w:lineRule="exact"/><w:ind w:left="1296" w:hanging="576"/></w:pPr>}, '' ],
  Footer => [ 'paragraph', 'footer', 'Normal', qq{<w:pPr><w:tabs><w:tab w:val="center" w:pos="4680"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>}, '' ],
  Centered => [ 'paragraph', 'Centered', 'Normal', qq{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>}, '' ],
  Single => [ 'paragraph', 'Single', 'Normal', qq{<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr>}, '' ],
);
for my $id (sort keys %style) {
  my ($type, $name, $based, $ppr, $rpr) = @{ $style{$id} };
  my $custom = ($id =~ /^(Centered|Single)$/) ? ' w:customStyle="1"' : '';
  my $b = $based ne '' ? qq{<w:basedOn w:val="$based"/>} : '';
  my $xml = qq{<w:style w:type="$type"$custom w:styleId="$id"><w:name w:val="$name"/>$b<w:qFormat/>$ppr$rpr</w:style>};
  my $re = qr{<w:style\s[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}s;
  if ($s =~ $re) { $s =~ s{$re}{$xml}s } else { $s =~ s{</w:styles>}{$xml</w:styles>}s }
}
open(my $out, ">", "word/styles.xml") or die; print $out $s; close $out;
PL
perl "$W/styles.pl" "$FONT" "$SIZE" "$FOOT_SIZE" "$PITCH" "$INDENT" "$MARGIN"

# footer with the page number (PAGE field; cached result 1), centred at 13 pt
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="$FOOT_SIZE"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="$FOOT_SIZE"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="$FOOT_SIZE"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="$FOOT_SIZE"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="$FOOT_SIZE"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Id="rId100" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' '[Content_Types].xml'

# body section: letter, 1 in margins, the page-number footer, Arabic numbering from 1
SECT="<w:sectPr><w:footerReference w:type=\"default\" r:id=\"rId100\"/><w:pgSz w:w=\"12240\" w:h=\"15840\"/><w:pgMar w:top=\"$MARGIN\" w:right=\"$MARGIN\" w:bottom=\"$MARGIN\" w:left=\"$MARGIN\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\"/><w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/></w:sectPr>"
SECT="$SECT" perl -0pi -e 'my $s = $ENV{SECT}; if (s{<w:sectPr\b.*?</w:sectPr>}{$s}s) { } else { s{</w:body>}{$s</w:body>}s }' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
names=$(find . -type f | sed 's|^\./||' | grep -v -x -F '[Content_Types].xml' | sort)
perl "$W/pack.pl" "$OUT" "$W/pkg" '[Content_Types].xml' $names
echo "$OUT"
