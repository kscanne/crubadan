#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

die "Usage: $0 xx URL" unless ($#ARGV == 1);
my $langcode = $ARGV[0];
my $url = $ARGV[1];

my $ok = 0;
my $code='';
open(RULES, '<:utf8', '/home/kps/seal/crubadan/normalize/rules.txt') or die "Could not open rules.txt: $!";
while (<RULES>) {
	chomp;
	s/ *#.*$//;  # strip comments
	next if m/^$/;  # includes lines that were just comments
	if (m/^LANG /) {
		$ok = 0;
		s/^LANG +//;
		my @langs = split(',');
		for my $l (@langs) {
			$ok = 1 if ($l eq $langcode);
		}
	}
	elsif (m/^URL /) {
		if ($ok) {
			s/^URL +//;
			$ok = 0 unless ($url =~ m/$_/);
		}
	}
	else {
		if ($ok) {
			s/^(s\/.+\/i?)$/$1g/;  # default is global substitution
			$code .= "$_; ";
		}
	}
}
close RULES;

while (<STDIN>) {
	eval $code;
	print;
}

exit 0;
