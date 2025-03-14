#!/usr/bin/env perl

use v5.38;
use Time::Piece;

my $year_month = localtime->strftime('%Y-%m');
my ($year, $month) = split /\-/, $year_month, 2;

my $IN = $ARGV[0];
die "Usage: $0 <input_folder> <output_folder> <year> <month>\nERROR: Missing input foler.\n"
    unless (defined $IN);

my $OUT = $ARGV[1];
die "Usage: $0 <input_folder> <output_folder> <year> <month>\nERROR: Missing output folder.\n"
    unless (defined $OUT);

my $YEAR  = $ARGV[2] || $year;
my $MONTH = $ARGV[3] || $month;

die "Usage: $0 <input_folder> <output_folder> <year> <month>\nERROR: Invalid year $YEAR.\n"
    unless ($YEAR > 0);

die "Usage: $0 <input_folder> <output_folder> <year> <month>\nERROR: Invalid month $MONTH.\n"
    unless ($MONTH >= 1 && $MONTH <= 12);

my $IN_FILE  = sprintf("%s/hcm-%04d-%02d.txt", $IN,  $YEAR, $MONTH);
my $OUT_FILE = sprintf("%s/hcm-%04d-%02d.txt", $OUT, $YEAR, $MONTH);

open(my $out, '>', $OUT_FILE)
    or die "Could not open file '$OUT_FILE' $!";
open(my $in,  '<', $IN_FILE)
    or die "Could not open file '$IN_FILE' $!";

my $i = 1;
#open (my $fh, '<', $F);
while (my $line = <$in>) {
    chomp $line;
    if ($line =~ /\:/) {
        $line =~ s/AM//g;
        $line =~ s/PM//g;
        $line =~ s/\t/ /g;
        $line =~ s/ +/ /g;
        (undef, $line) = split /\s/, $line, 2;
        my @times = split /\s/,$line;
        my @ptimes = @times[0,3,5,7,9];
        my $j = 0;
        foreach my $time (@ptimes) {
            $time = sprintf("%04d-%02d-%02d %02d:%02d", $YEAR, $MONTH, $i, split /\:/, $time);
            ($j == 0) ? ($time .= '|F'):($time .= '|R');
            $j++;
        }
        print $out join("\n", @ptimes), "\n";
        $i++;
    };
}

close $in;
close $out;
