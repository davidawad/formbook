# Gives every section break the header and footer of the final section (a section without references
# would show none, in Word and LibreOffice). Usage: perl fix-sections.pl word/document.xml
local $/;
my $f = shift;
open my $in, "<:encoding(UTF-8)", $f or die "fix-sections: $f: $!"; my $x = <$in>; close $in;
my ($last) = $x =~ m{(<w:sectPr>(?:(?!<w:sectPr>).)*?</w:sectPr>)\s*</w:body>}s or die "fix-sections: no final sectPr\n";
my @refs = $last =~ m{(<w:(?:header|footer)Reference [^>]*/>)}g;
die "fix-sections: the final section has no header/footer reference\n" unless @refs;
my $refs = join '', @refs;
$x =~ s{<w:sectPr>((?:(?!<w:sectPr>).)*?)</w:sectPr>}{
  my $body = $1;
  $body =~ /footerReference/ ? "<w:sectPr>$body</w:sectPr>" : "<w:sectPr>$refs$body</w:sectPr>"
}gse;
open my $out, ">:encoding(UTF-8)", $f or die; print $out $x; close $out;
