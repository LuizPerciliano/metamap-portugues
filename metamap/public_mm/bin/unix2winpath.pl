# convert MINGW unix paths to microsoft
#
# MINGW path:
#  /g/Projects/test/public_mm/bin:/g/Projects/test/public_mm/foo
# equivalent Microsoft path:
#  G:\Projects\test\public_mm\bin;G:\Projects\test\public_mm\foo
#
# this won't work for paths without a single character directory
# (e.g. /usr/bin)

use strict;
if (length(@ARGV) > 0) {
  my $unixpath = $ARGV[0];
  my @unixfilenames = split(":",$unixpath);
  my @winfilenames = ();
  foreach my $unixfn (@unixfilenames) {
    my @components = split("/",$unixfn);
    if (length ($components[1]) > 1) {
      printf(STDERR "%s not a windows-like MINGW path.\n", $unixfn);
    }
    my $winfn = sprintf("%s:\\%s", $components[1], join('\\',@components[2 .. $#components]));
    unshift (@winfilenames, $winfn);
  }
  printf("%s\n",join(';', @winfilenames));
}
exit 0;
