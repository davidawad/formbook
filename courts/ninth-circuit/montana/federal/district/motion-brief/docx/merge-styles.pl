# usage: perl merge-styles.pl styles.xml new-styles.xml   (replaces or adds the named styles; docDefaults replaced)
my ($sf, $nf) = @ARGV;
local $/;
open my $h, '<', $sf or die "$sf: $!"; my $s = <$h>; close $h;
open my $n, '<', $nf or die "$nf: $!"; my $new = <$n>; close $n;
if ($new =~ /(<w:docDefaults>.*?<\/w:docDefaults>)/s) {
  my $dd = $1;
  $s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults in $sf";
}
while ($new =~ /(<w:style [^>]*?w:styleId="([^"]+)".*?<\/w:style>)/gs) {
  my ($block, $id) = ($1, $2);
  if ($s =~ s{<w:style [^>]*?w:styleId="\Q$id\E".*?</w:style>}{$block}s) { }
  else { $s =~ s{</w:styles>}{$block</w:styles>}s or die "no </w:styles>"; }
}
open my $o, '>', $sf or die; print $o $s; close $o;
