#!/usr/bin/perl -w

# This Perl script mimics the behavior of mm_tokenizer -ml, and runs about 30 times faster.

use strict;

my $line;

my $INFILE  = $ARGV[0];
my $OUTFILE = $ARGV[1];

open INFILE,  " < $INFILE";
open OUTFILE, " > $OUTFILE";

while (<INFILE>) {
    chomp;
    # change all strings of non-alnums, whitespace, or underscore to just one whitespace
    ( $line = $_ ) =~ s/[\W\s_]+/ /g;
    # remove leading blanks
    $line =~ s/^\s+//;
    # remove trailing blanks
    $line =~ s/\s+$//;
    # change each blank to a <CR>
    $line =~ s/\s/\n/g;
    # lowercase everything
    $line =~ s/(.*)/\L$1/g;
    # Simply print the results if anything is left in $line other than just a "\n":
    # If an input line consists of only [\W\s_] chars, nothing will be left in $line,
    # and those empty lines should be ignored.
    # The <CR>s in $line will cause each token to be printed on its own line.
    printf OUTFILE "%s\n", $line if $line ne "";

} # while (<>)

close INFILE;
close OUTFILE;
