#!/bin/nawk -f

BEGIN {
     max = 0
     maxline = ""
}
{
     if (length($0) > max) {
          max = length($0)
          maxline = $0
     }
}
END {
     print "Maximum line length: " max
     print maxline
}
