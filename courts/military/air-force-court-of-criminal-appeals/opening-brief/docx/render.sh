#!/bin/sh
# AFCCA brief, DOCX engine: sh docx/render.sh <court-dir> <sample.md> <out.docx>
# tools/render-docx.sh calls this when it is present, and it owns the .docx. Works in its own temp dir only.
# An indexed sample (index: true) takes two passes. Pass 1 writes the heading and citation texts (afcca.lua,
# AFCCA_TARGETS) and lays the document out in LibreOffice. Perl finds the page of each text in that PDF, and pass 2
# writes those page labels as the cached result of each PAGEREF field (AFCCA_PAGES). Word and LibreOffice recompute
# the fields on update; the cache shows the same numbers before that. A sample without an index takes one pass.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
case $3 in /*) OUT=$3 ;; *) OUT=$(pwd)/$3 ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$W"
(cd "$COURT" && AFCCA_TARGETS="$W/targets.tsv" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/afcca.lua" "$SAMPLE" -o "$W/pass1.docx")
if grep -q '^I.index.1$' "$W/targets.tsv"; then
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 \
    || "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 \
    || { cat "$W/soffice.log" >&2; echo "render.sh: pass 1 PDF failed" >&2; exit 1; }
  pdftotext "$W/pass1.pdf" "$W/pass1.txt"
  perl - "$W/targets.tsv" "$W/pass1.txt" "$W/pages.tsv" <<'PL'
use strict;
use warnings;
use utf8;
my ($tf, $txt, $out) = @ARGV;
open my $in, '<:encoding(UTF-8)', $txt or die "$txt: $!";
my $all = do { local $/; <$in> };
close $in;
my @pages = split /\f/, $all;
pop @pages if @pages && $pages[-1] =~ /^\s*$/;
sub norm {
  my $s = shift;
  $s =~ s/\x{2060}//g;
  $s =~ s/\s+/ /g;
  $s =~ s/^ //;
  $s =~ s/ $//;
  return lc $s;
}
sub roman {
  my $n = shift;
  my @v = ([1000, 'm'], [900, 'cm'], [500, 'd'], [400, 'cd'], [100, 'c'], [90, 'xc'], [50, 'l'], [40, 'xl'], [10, 'x'], [9, 'ix'], [5, 'v'], [4, 'iv'], [1, 'i']);
  my $s = '';
  for my $p (@v) { while ($n >= $p->[0]) { $s .= $p->[1]; $n -= $p->[0] } }
  return $s;
}
my @np = map { norm($_) } @pages;
open my $tfh, '<:encoding(UTF-8)', $tf or die "$tf: $!";
my ($index, @heads, @hits) = (0);
while (my $line = <$tfh>) {
  chomp $line;
  my ($k, $n, $x) = split /\t/, $line, 3;
  next unless defined $x;
  if ($k eq 'I') { $index = $x eq '1' ? 1 : 0 }
  elsif ($k eq 'H') { push @heads, [$n, $x] }
  elsif ($k eq 'T') { push @hits, [$n, $x] }
}
close $tfh;
# the body starts on the first page with the TO THE HONORABLE line when the front matter is indexed (1-based)
my $bs = 1;
if ($index) {
  my $first = 0;
  for my $i (0 .. $#np) { if (index($np[$i], 'to the honorable') >= 0) { $first = $i + 1; last } }
  $bs = $first ? $first : 1;
}
sub label {
  my $p = shift;
  return roman($p) if $index && $p < $bs;
  return $p - $bs + 1;
}
my %label;
for my $list (\@heads, \@hits) {
  my $ptr = $bs - 1;
  for my $t (@$list) {
    my ($name, $text) = @$t;
    my $needle = norm($text);
    $needle = substr($needle, 0, 60) if length($needle) > 60;
    my $found;
    for my $i ($ptr .. $#np) {
      if (length($needle) && index($np[$i], $needle) >= 0) { $found = $i; last }
    }
    if (defined $found) {
      $ptr = $found;
      $label{$name} = label($found + 1);
    } else {
      warn "render.sh: no page found for '$needle' ($name); the cached label stays 1\n";
    }
  }
}
open my $ofh, '>:encoding(UTF-8)', $out or die "$out: $!";
for my $name (sort keys %label) { print $ofh "$name\t$label{$name}\n" }
close $ofh;
PL
  (cd "$COURT" && AFCCA_PAGES="$W/pages.tsv" pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$D/afcca.lua" "$SAMPLE" -o "$OUT")
else
  (cd "$COURT" && pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$D/afcca.lua" "$SAMPLE" -o "$OUT")
fi
echo "$OUT" >&2
