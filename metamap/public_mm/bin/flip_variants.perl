#!/usr/bin/perl -w

# This Perl script implements flip_variants, which had originally been written in Prolog.
# This version runs about 20 times faster.

use strict;

my $line;
my ( $Word, $WordCat, $Variant, $VariantCat, $VarLevel, $History, $Roots );
my ( $FlippedHistory );

my $INFILE = $ARGV[0];
my $OUTFILE = $ARGV[1];

open INFILE,  " < $INFILE";
open OUTFILE, " > $OUTFILE";

while (<INFILE>) {
    chomp;
    $line = $_;
    ( $Word, $WordCat, $Variant, $VariantCat,
      $VarLevel, $History, $Roots ) = split /\|/, $line;

    # Variant type abbreviations and distances:
    # "a" (2): AA
    # "d" (3): Derivation
    # "e" (2): AA expansion
    # "i" (1): Inflection
    # "p" (0): Spelling 
    # "s" (2): Synonym

    # Flip history, by
    # (1) changing "a" to "e",
    # (2) changing "e" to "a", and
    # (3) moving an initial "i" to the end of the history

    # (1) a1: first change "a" to "X"
    ( $FlippedHistory = $History ) =~ s/a/X/g;
    # (2) 2: then and change "e" to "a"
    $FlippedHistory =~ s/e/a/g;
    # (3) a2: finally change "X" to "e"
    $FlippedHistory =~ s/X/e/g;
    # (4): if the history begins with "i",
    if ( $FlippedHistory =~ /^i/ ) {
       # remove the leading "i",
       $FlippedHistory =~ s/^i//;
       # add the "i" to the end
       $FlippedHistory .= "i";
    }

    # Set Roots to null, because we don't need them in the variants files.
    $Roots = "[]";

    if ( ! (  ( $Variant eq $Word )
	   && ( $WordCat eq "none" )
	   && ( $VarLevel == 0 ) ) ) {
	printf OUTFILE "%s|%s|%s|%s|%s|%s|%s\n",
    	       $Variant, $VariantCat, $Word, $WordCat, $VarLevel, $FlippedHistory, $Roots;
    } # if ...

    # This is a new piece of logic added by FML during the 2011AA Migration:
    # Keep all AA --> Expansion lines intact
    if ( $History =~ /e/ ) {
	printf OUTFILE "%s|%s|%s|%s|%s|%s|%s\n",
    	       $Word, $WordCat, $Variant, $VariantCat, $VarLevel, $History, $Roots;
    } # if ( $History =~ /e/ )


    $VarLevel = 0;
    $FlippedHistory = "";
    printf OUTFILE "%s|%s|%s|%s|%s|%s|%s\n",
    	   $Variant, $VariantCat, $Variant, $VariantCat, $VarLevel, $FlippedHistory, $Roots;
   	
} # while (<>)

close INFILE;
close OUTFILE;
