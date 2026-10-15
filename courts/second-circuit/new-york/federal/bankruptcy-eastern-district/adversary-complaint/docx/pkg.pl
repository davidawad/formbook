#!/usr/bin/perl
# Zip helper for the docx build. This box has no unzip or zip; perl's core IO::*Zip modules do the same.
#   perl pkg.pl unpack <file.docx> <dir>    extract every part into <dir> (created if missing)
#   perl pkg.pl pack <dir> <file.docx>      zip <dir> into a new <file.docx>, [Content_Types].xml first
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Find;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use IO::Compress::Zip qw($ZipError);

my ($mode, $a, $b) = @ARGV;
die "usage: pkg.pl unpack|pack <src> <dst>\n" unless defined $b;

sub entry_names {
    my ($file) = @_;
    open my $fh, '<:raw', $file or die "open $file: $!\n";
    local $/;
    my $zip = <$fh>;
    close $fh;
    my $eocd = rindex($zip, "PK\x05\x06");
    die "$file: no zip end record\n" if $eocd < 0;
    my $count = unpack('v', substr($zip, $eocd + 10, 2));
    my $off = unpack('V', substr($zip, $eocd + 16, 4));
    my @names;
    for (1 .. $count) {
        die "$file: bad central directory\n" unless substr($zip, $off, 4) eq "PK\x01\x02";
        my ($nlen, $xlen, $clen) = unpack('v v v', substr($zip, $off + 28, 6));
        push @names, substr($zip, $off + 46, $nlen);
        $off += 46 + $nlen + $xlen + $clen;
    }
    return @names;
}

if ($mode eq 'unpack') {
    make_path($b);
    for my $name (entry_names($a)) {
        next if $name =~ m{/$};
        my $data;
        unzip($a => \$data, Name => $name) or die "unzip $name: $UnzipError\n";
        my $path = "$b/$name";
        make_path(dirname($path));
        open my $out, '>:raw', $path or die "write $path: $!\n";
        print {$out} $data;
        close $out;
    }
} elsif ($mode eq 'pack') {
    my @files;
    find({ no_chdir => 1, wanted => sub { push @files, $File::Find::name if -f $_ } }, $a);
    my @rel = map { (my $r = $_) =~ s{^\Q$a\E/}{}; $r } @files;
    my @order = sort { ($b eq '[Content_Types].xml') <=> ($a eq '[Content_Types].xml') or $a cmp $b } @rel;
    my $z;
    for my $i (0 .. $#order) {
        open my $fh, '<:raw', "$a/$order[$i]" or die "read $order[$i]: $!\n";
        local $/;
        my $data = <$fh>;
        close $fh;
        if ($i == 0) {
            $z = IO::Compress::Zip->new($b, Name => $order[$i]) or die "zip $b: $ZipError\n";
        } else {
            $z->newStream(Name => $order[$i]);
        }
        print {$z} $data;
    }
    $z->close;
} else {
    die "unknown mode $mode\n";
}
