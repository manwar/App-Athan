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

my $IN_FILE  = sprintf("%s/%04d-%02d.txt", $IN, $YEAR, $MONTH);
my $OUT_FILE = sprintf("%s/%04d-%02d.txt", $OUT, $YEAR, $MONTH);

open(my $out, '>', $OUT_FILE)
    or die "Could not open file '$OUT_FILE' $!";
open(my $in,  '<', $IN_FILE)
    or die "Could not open file '$IN_FILE' $!";

while (my $line = <$in>) {
    chomp($line);

    $line =~ s/ +/ /g;
    $line =~ s/\t/ /g;
    my @columns = split /\s/, $line;

    my $day = sprintf("%02d", $columns[0]);
    my @selected_times = ($columns[1], $columns[4], $columns[6], $columns[9], $columns[11]);

    my $i = 0;
    foreach my $time (@selected_times) {
        my ($hour, $minute) = split /:/, $time;
        $hour = sprintf("%02d", $hour);
        $minute = sprintf("%02d", $minute);
        $time = ($i == 0)? "$hour:$minute|F" : "$hour:$minute|R";
        $i++;
    }

    foreach my $time (@selected_times) {
        print $out "$year-$month-$day $time\n";
    }
}

close $in;
close $out;
