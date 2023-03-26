#!/usr/bin/perl -w

# Extract source information from mrconso.eng producing records of the form
#           <CUI>|<SUI>|<I>|<STR>|<SAB>|<TTY>
#           where <I> is the ith record for <CUI>.

# Call: extract_mrconso_sources.RRF MRCONSO_File cui_sourceinfo.txt

# Schema of MRCONSO input file:
#   0|  1| 2|  3|  4|  5|     6|  7|   8|   9|  10| 11| 12|  13| 14| 15|      16| 17
# CUI|LAT|TS|LUI|STT|SUI|ISPREF|AUI|SAUI|SCUI|SDUI|SAB|TTY|CODE|STR|SRL|SUPPRESS|CVF
# C0000005|ENG|P|L0000005|PF|S0007492|Y|A7755565||M0019694|D012711|MSH|PEN|D012711|(131)I-Macroaggregated Albumin|0|N||

# The Prolog code on which this script is based can be found at
# /nfsvol/nls/specialist/SKR/tools/extract_mrconso_sources/extract_mrconso_sources.pl.
# Because the Prolog version is always called with --first_of_each_source_only,
# that behavior was replicated in the Perl version.

# The Perl version runs about 30 times faster than the Prolog version when timed using
# the 2012AA MRCONSO.RRF file.

use strict;
use Getopt::Long;

my $Interval   = 10000;
my $TotalLines = -9999;

my $Options = GetOptions(
	"Interval:s"    => \$Interval,
	"TotalLines:s"  => \$TotalLines
		    );
my $Line;
my ( $CUI, $SUI, $STR, $SAB, $TTY );
my $PrevCUI;
my @Queue = ();
my $LineCount = 0;

my $InputFile  = $ARGV[0];
my $OutputFile = $ARGV[1];

# $InputFile should be an MRCONSO.RRF file
open INPUT,  " < $InputFile";
open OUTPUT, " > $OutputFile";

$Line = <INPUT>;
chomp $Line;
++$LineCount;
# Get the first line of the input file and grab the desired fields.
# ( $CUI, $SUI, $STR, $SAB, $TTY ) = ( split /\|/, $Line )[0,5,14,11,12];
my $ArrRef = get_field_data($Line, $LineCount, $TotalLines, $InputFile);
# Push on the queue an anonymous array containing the desired fields.
# push @Queue, [$CUI, $SUI, $STR, $SAB, $TTY];
push @Queue, $ArrRef;

while (<INPUT>) {
    chomp;
    $Line = $_;
    ++$LineCount;

    $ArrRef = get_field_data($Line, $LineCount, $TotalLines, $InputFile);

    # If the current line's CUI is different from that of those already in the queue,
    # empty the queue by calling generate_CUI_output.
    # $$ArrRef[0] is the CUI of the line that was just read in.
    # $Queue[0][0] is the CUI of the first line already in thee queue
    # (and all the other lines in the queue as well).

    generate_CUI_output(\@Queue) if ( $$ArrRef[0] ne $Queue[0][0] );

    # Add the current line's data to the queue unconditionally.
    push @Queue, $ArrRef;

} # while (<INPUT>)

# After all the input has been read, empty whatever is in the queue.
generate_CUI_output(\@Queue);

close INPUT;
close OUTPUT;

################################################################
##################### END of main program ######################
################################################################

# return an anonymous array consisting of [ $CUI, $SUI, $STR, $SAB, $TTY ];
sub get_field_data {

    my ( $Line, $LineCount, $TotalLines, $InputFile ) = @_;

    # my ( $CUI, $SUI, $STR, $SAB, $TTY ) = ( split /\|/, $Line )[0,5,14,11,12];
    # return [ $CUI, $SUI, $STR, $SAB, $TTY ];

    announce_progress($LineCount, $TotalLines, $InputFile )
	if ( $LineCount % $Interval == 0 ) || ( eof INPUT );

    return [ ( split /\|/, $Line )[0,5,14,11,12]];

} # sub get_field_data


# Empty the queue, printing the first line for each SAB encountered.
# We take the lines off Queue by shifting rather than popping,
# i.e., off the front (lower-indexed) of the queue rather than the end,
# because the lines in the MRCONSO input file appear highest-MRRANK first,
#  and that's the order in which we want to process them.

sub generate_CUI_output {
   my ( $Queue ) = @_;
    
   my %SABHash = ();
   my $Count = 0;

   # $Queue is a reference to @Queue,
   # which is an array of anonymous array references.
   # Each array reference is of the form [ $CUI, $SUI, $STR, $SAB, $TTY ].
   while ( my $ArrRef = shift @$Queue ) {
       my ( $CUI, $SUI, $STR, $SAB, $TTY ) = @$ArrRef;
       # print "$CUI|$SUI|$STR|$SAB|$TTY\n";
       # Write the first line from each SAB:
       # If we have not yet seen this SAB,
       # * increment the counter,
       # * print the output, and
       # * record the SAB in %SABHash so that
       #   subsequent rows for this CUI and SAB will not be printed.
       if ( ! defined $SABHash{$SAB} ) {
	   ++$Count;
	   print OUTPUT "$CUI|$SUI|$Count|$STR|$SAB|$TTY\n";
	   $SABHash{$SAB} = 1;
       } # if ( ! defined $SABHash{$SAB} )
   } # forech my $ArrRef ( @Queue )
} # sub generate_CUI_output


sub announce_progress {
   my ( $LineCount, $TotalLines, $InputFile ) = @_;

   # We want to print a message such as
   # Processed 760000 lines of 10810680 lines of file MRCONSO.RRF
   # But, print "COMPLETED" instead of "Processed" at the end of the input.
   # Also, if we don't know the total number of lines, omit "of 10810680 lines ".

   # $TotalLines is the number of lines in the input file,
   # if it's provided via the --TotalLines command-line option;
   # if $TotalLines is not provided, it defaults to -9999.

   # my $Status = ( $LineCount == $TotalLines ) ? "COMPLETED" : "Processed";
   my $Status = eof INPUT ? "COMPLETED" : "Processed";
   my $TotalMsg = ( $TotalLines > 0 ) ? "of $TotalLines lines " : "";
   print "$Status $LineCount lines ${TotalMsg}of file $InputFile\n";

} # sub announce_progress
