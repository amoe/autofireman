use strict;
use warnings;
use v5.16.3;

my $bytes_so_far = 0;
while (<>) {
    /^COPY / && printf "%d:%d:%s", $., $bytes_so_far, $_;
    $bytes_so_far += length;
}
