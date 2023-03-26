#!/bin/awk -f 
# or !/bin/nawk -f  (on Solaris if you don't have GNU AWK installed)
#
# Module:   Character Tally
#
# Purpose:  Count the number of characters (including newlines) in a file


BEGIN {
    total = 0;
}
{
    total = total + length($0) + 1; # add one character for newline
}
END {
    print total
}