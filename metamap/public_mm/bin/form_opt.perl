
while (<>) {
    if (/^([^\|]*)\|([^\|]*)\|(.*)$/) {  # three or more fields
        $col1 = $1;
        $col2 = $2;
        $rest = $3;
        if ($col1 eq $col2) {
            print $col1, "|X|", $rest, "\n";
        } else {
            print;
        }
    } elsif (/^([^\|]*)\|([^\|]*)$/) {  # two fields
        $col1 = $1;
        $col2 = $2;
        chop $col2;
        if ($col1 eq $col2) {
            print $col1, "|X\n";
        } else {
            print;
        }
    } else {
        print;
    }
}
