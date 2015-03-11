#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use LWP::Simple;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, "utf8";

my $key = "[INSERT KEY HERE]";
my $DAM_ID;
if (defined $ARGV[0] and $ARGV[0] =~ /(([A-Z]|[0-9]){3}[A-Z]{4}[1-2][A-Z]{2})/) {
    $DAM_ID = $1;
}
else {
    die "You must supply a valid DAM ID!\n";
}
my $url = "http://dbt.io/text/verse?key=$key&dam_id=$DAM_ID&reply=html&v=2";

my $bibleText = get($url);
die "Can't get $url" if (! defined $bibleText);

foreach (split("\n", $bibleText)) {
    #Capture the Verses
    if ($_ =~ /verse_text: (.+)$/) {
        print "$1\n";
    }
}
