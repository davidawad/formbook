# Replaces each <w:style> of NEW in TARGET that has the same styleId, or appends it when TARGET has none.
# Usage: perl patch-styles.pl NEW.xml TARGET.xml   (called by make-reference.sh)
use strict;
use warnings;

sub slurp {
  my ($path) = @_;
  open(my $fh, '<:encoding(UTF-8)', $path) or die "patch-styles.pl: cannot read $path\n";
  local $/;
  my $text = <$fh>;
  close($fh);
  return $text;
}

my ($new_path, $target_path) = @ARGV;
my $new = slurp($new_path);
my $xml = slurp($target_path);
while ($new =~ m{(<w:style\s[^>]*?w:styleId="([^"]+)".*?</w:style>)}sg) {
  my ($block, $id) = ($1, $2);
  next if $xml =~ s{<w:style\s[^>]*?w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$block}s;
  $xml =~ s{</w:styles>}{$block</w:styles>}s;
}
open(my $out, '>:encoding(UTF-8)', $target_path) or die "patch-styles.pl: cannot write $target_path\n";
print {$out} $xml;
close($out);
