
while (<>) {
    # parse line
    /^(.*)\|(.*)\|(.*)\|(.*)$/;
    $item = $1;
    $itemcat = $2;
    $synonym = $3;
    $synonymcat = $4;
    print $item, "|", $itemcat, "|", $synonym, "|", $synonymcat, "\n";
    print $synonym, "|", $synonymcat, "|", $item, "|", $itemcat, "\n";
}
