#!/usr/bin/perl
# Reads MD5, URL syntax from the stdin and reports non-sorted count for 
# each favicon
# Copyright (C) 2008. Vlatko Kosturjak - Kost. Distributed under GPL v2+

use strict;

my %faviconscount;
my %faviconsurl;
my $totalurls;

while (<STDIN>) {
	chomp;
	my ($md5, $url) = split (",");
	trim($md5);
	trim($url);
	$totalurls++;
	$faviconscount{$md5}++;
	$faviconsurl{$md5}=$url;
	# print STDERR "$totalurls\n" if ($totalurls % 4096==0);
}

print STDERR "Total number: $totalurls\n";

while (my ($md5, $count) = each (%faviconscount)) {
	print "$count:$md5:".$faviconsurl{$md5}."\n";
}


sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

