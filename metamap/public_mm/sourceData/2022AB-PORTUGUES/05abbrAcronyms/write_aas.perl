
while (<>) {
    # parse line
    /^(.*)\|(.*)\|(.*)\|(.*)$/;
    $aa = $1;
    $expansion = $2;
    $category = $3;
    $type = $4;
    print $aa, "|", $expansion, "|e|", $category, "\n";
    print $expansion, "|", $aa, "|a|", $category, "\n";
}
