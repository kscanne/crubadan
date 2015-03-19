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
my $url = "http://dbt.io/library/language?key=$key&v=2&reply=html";

my $content = get($url);
die "Can't get $url" if (! defined $content);

foreach (split("<ul><li>", $content)) {
    if ($_ =~ /language_code: ?([^<]+)<.+language_iso: ?([^<]+)</) {
        my $DBP_code = $1;
        my $ISO_code = $2;
        my $url2 = "http://dbt.io/library/volume?key=$key&media=text&reply=html&language_code=$1&v=2";
        my $content2 = get($url2);
        my @split = split("<ul><li>", $content2);
        if (scalar(@split) > 1) {
            print "$DBP_code $ISO_code";
            foreach (@split) {
                if ($_ =~ /dam_id: ?([^<]+)</) {
                    print " $1";
                }
            }
            print "\n";
        }            
    }
}
