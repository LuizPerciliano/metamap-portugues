#!/usr/bin/perl -w

# This new and more efficient version has been validated against the 2007 and 2008 lexicons.

use strict;

my ( $Base, $Cat, $Acr, $Abbr );

while (<>)
{
    chomp;
    if (/^{base=(.*)$/)
    {
	$Base = $1;
	next;
    }
    elsif (/^\s*cat=(.*)$/)
    {
	$Cat = $1;
	next;
    }
    elsif (/^\s*acronym_of=(.*)$/)
    {
	$Acr = $1;
	# acronym_of lines look like
	# acronym_of=androgenic anabolic agent|E0429486
        # acronym_of=aneurysm of ascending aorta
        # Get rid of the "|E.*$" if it exists
	$Acr =~ s/\|.*$//;
	printf "%s|%s|%s|acronym\n", $Base, $Acr, $Cat;
    }
    elsif (/^\s*abbreviation_of=(.*)$/)
    {
	# abbreviation_of lines look like
        # abbreviation_of=aflatoxin B1|E0007696
        # abbreviation_of=axiolabial
        # Get rid of the "|E.*$" if it exists
	$Abbr = $1;
	$Abbr =~ s/\|.*$//;
	printf "%s|%s|%s|abbreviation\n", $Base, $Abbr, $Cat;
    }
}
