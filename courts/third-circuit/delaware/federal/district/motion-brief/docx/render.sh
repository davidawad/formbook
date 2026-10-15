#!/bin/sh
# D. Del. motion brief, DOCX engine: builds one sample's .docx (docs/DOCX.md; EVAL-LOOP "Engines").
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc writes the document with reference.docx and ded.lua. ded.lua writes the cover, contents and citations
# as raw WordprocessingML, and its section breaks name the page-number footer as rId100; pandoc gives its own
# footer relationship another id, so this script points rId100 at that id (a dangling reference makes Word
# offer a repair). Needs pandoc, perl with IO::Compress::Zip and IO::Uncompress::Unzip, xmllint.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

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

(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/ded.lua" "$SAMPLE" -o "$W/out.docx")
mkdir "$W/pkg"
perl "$W/unpack.pl" "$W/out.docx" "$W/pkg"
cd "$W/pkg"
FID=$(perl -0ne 'while (/<Relationship\b[^>]*>/g) { my $r = $&; if ($r =~ /\/footer"/) { my ($id) = $r =~ /Id="([^"]+)"/; print "$id\n"; last } }' word/_rels/document.xml.rels)
[ -n "$FID" ] || { echo "render.sh: pandoc wrote no footer part" >&2; exit 1; }
FID="$FID" perl -0pi -e 's/r:id="rId100"/r:id="$ENV{FID}"/g' word/document.xml
if grep -q 'rId100' word/document.xml; then echo "render.sh: rId100 is still referenced" >&2; exit 1; fi
for part in word/document.xml word/styles.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
names=$(find . -type f | sed 's|^\./||' | grep -v -x -F '[Content_Types].xml' | sort)
perl "$W/pack.pl" "$OUT" "$W/pkg" '[Content_Types].xml' $names
echo "$OUT"
