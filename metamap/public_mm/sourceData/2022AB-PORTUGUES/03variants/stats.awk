BEGIN {
     min = "undefined"
     max = "undefined"
     sum = 0
     sumsq = 0
}
{
     sum += $0
     sumsq += $0 ^ 2
     if ((min == "undefined") || ($0 < min)) {
          min = $0
     }
     if ((max == "undefined") || ($0 > max)) {
          max = $0
     }
}
END {
     print "min: " min "  max: " max
     average = sum / NR
     print average " = " sum "/" NR
     sd = sqrt((sumsq - ((sum ^ 2) / NR)) / (NR - 1))
     print "sd = " sd
}
