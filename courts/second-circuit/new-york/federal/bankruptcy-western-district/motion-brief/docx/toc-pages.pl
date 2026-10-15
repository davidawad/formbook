#!/usr/bin/perl
# Prints the body page number of each heading (levels 1 to 3) of a sample, in order, measured on a rendered PDF.
# Usage: perl toc-pages.pl <rendered.pdf> <sample.md>
# The pages before the body are the cover and the table of contents: the table of contents is the run of pages up
# to the last page with dot leaders. Body page 1 is the page after it (the table of contents is roman in the
# document; the body restarts at 1). Headings are matched in order, on their whitespace-normalized text.
use strict;
use warnings;

my ($pdf, $md) = @ARGV;
die "usage: toc-pages.pl <rendered.pdf> <sample.md>\n" unless defined $md;

sub norm {
  my $s = shift;
  $s =~ s/\s+/ /g;
  $s =~ s/^ //;
  $s =~ s/ $//;
  return $s;
}

open my $m, '<:encoding(UTF-8)', $md or die "toc-pages: $md: $!\n";
my @lines = <$m>;
close $m;
my $i = 0;
if (@lines && $lines[0] =~ /^---\s*$/) {
  $i = 1;
  $i++ while $i < @lines && $lines[$i] !~ /^---\s*$/;
  $i++;
}
my @heads;
for (; $i < @lines; $i++) {
  if ($lines[$i] =~ /^#{1,3}\s+(.*?)\s*$/) {
    my $t = $1;
    $t =~ s/[*_]//g;
    push @heads, norm($t);
  }
}

my ($n) = `pdfinfo "$pdf"` =~ /Pages:\s+(\d+)/ or die "toc-pages: cannot read $pdf\n";
my @text = (undef);
for my $p (1 .. $n) {
  my $t = `pdftotext -f $p -l $p -raw "$pdf" -`;
  $text[$p] = norm($t);
}

my $toc_last = 0;
for my $p (2 .. $n) {
  $toc_last = $p if $text[$p] =~ /(\.\s?){8,}/;
}
die "toc-pages: no table of contents (dot leaders) found in $pdf\n" unless $toc_last;

my $p = $toc_last + 1;
for my $h (@heads) {
  while ($p <= $n && index($text[$p], $h) < 0) { $p++ }
  die "toc-pages: heading not found after the table of contents: $h\n" if $p > $n;
  print(($p - $toc_last), "\n");
}
