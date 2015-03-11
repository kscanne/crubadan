#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use LWP::Simple;
use POSIX qw(strftime);

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $key = "[INSERT KEY HERE]";
my $dateOfLastUpdate;
if (defined $ARGV[0] and $ARGV[0] =~ /([0-9]{4}-[0-1][0-9]-[0-3][0-9])/) {
    $dateOfLastUpdate = $1;
}
else {
    $dateOfLastUpdate = strftime("%Y-%m-", localtime) . "01";
}
my $url = "http://dbt.io/library/volume?key=$key&media=text&updated=$dateOfLastUpdate&reply=html&v=2";

my $content = get($url);
die "Can't get $url" if (! defined $content);

foreach (split("\n", $content)) {
    # Capture DAM ID
    if ($_ =~ /dam_id: ([^<]+)</) {
        print "$1\n";
    }
}
