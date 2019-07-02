use strict;
use warnings;
use v5.20.2;
use autodie qw(:all);

# Can use head -c  to trim off the appropriate parts of the file.
# Can also use dd

my $bytes_so_far = 0;
while (<>) {
    /^COPY / && printf "%d:%d:%s", $., $bytes_so_far, $_;
    $bytes_so_far += length;
}
