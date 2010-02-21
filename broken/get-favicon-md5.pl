#!/usr/bin/perl
# Reads URLs from the stdin and reports non-sorted count for each favicon
# Copyright (C) 2008. Vlatko Kosturjak - Kost. Distributed under GPL v2+

use strict;

# use 5.008;
use threads;
use LWP::UserAgent;
use Digest::MD5 qw(md5_hex);

my $totalurls;
my $totalfavicons;

my @thread;
my $t=0;
my $i;
my $maxthreads=192;

while (<STDIN>) {
	chomp;
	$totalurls++;
	next if (!/^http/); # skip ftp/gopher/etc links...
	if ($t<$maxthreads) {
		($thread[$t])=threads->create(\&getfavicon,$_);
		$t++;
	} else {	
		my $toexit=0;
		while ($toexit==0) {	
			for ($i=0; $i<$t; $i++) {
				if ($thread[$i]->is_joinable()) {
					my @rval = $thread[$i]->join;
					if ($rval[0]==1) {
						print $rval[1];
						print ",";
						print $rval[2];
						print "\n";
						$totalfavicons++;
					}
					($thread[$i])=threads->create(\&getfavicon,$_);
					$toexit=1;
					last;
				}
			}
		}
	}
	print STDERR "$totalurls\n" if ($totalurls % 128==0);
}

# make sure all threads are finished
for ($i=0; $i<$t; $i++) {
	my @retval = $thread[$i]->join;
	if ($retval[0]==1) {
		print $retval[1];
		print ",";
		print $retval[2];
		print "\n";
		$totalfavicons++;
	}
}

print STDERR "Total: $totalfavicons favicons found from $totalurls URLs\n";

sub getfavicon {
	my ($url) = @_;
	my @retv;
	my $ua = LWP::UserAgent->new;
	$ua->agent("GoogleBot 2.1");
	my $faviconurl = $url."/favicon.ico";
	my $req = HTTP::Request->new(GET => $faviconurl);
	my $res = $ua->request($req);

	$retv[0]=0;
	if ($res->is_success) {
		$retv[0]=1;
		$retv[1]=md5_hex($res->content);
		$retv[2]=$url;
	}
	return @retv;
}

