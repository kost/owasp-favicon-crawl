#!/usr/bin/perl
# Reads DMOZ RDF format and outputs URLs (one per line) on stdout
# Copyright (C) 2008. Vlatko Kosturjak - Kost. Distributed under GPL v2+

use strict;
use XML::SAX;
use Getopt::Long;

my $baseurl;
my $rdffile;
my $stat = GetOptions(
    "b|base" => \$baseurl,
    "f|file=s" => \$rdffile,
    "h|help|?" => \&usage
);

usage() if (!$rdffile);

my $handler = RDFHandler->new();
$handler->sbaseurl() if ($baseurl);
my $parser = XML::SAX::ParserFactory->parser(
Handler => $handler
);

$parser->parse_uri($rdffile);

sub usage {
    use File::Basename;
    my $command = basename($0);
    print qq($command: DMOZ links extractor by Vlatko Kosturjak, Kost. GPL v2+
Usage: $command [-b] -f <dmozrdffile>
Options:	-f parse <dmozrdffile> (use - for stdin)
		-b display only base URL
		-h display help 

Links will be extracted to stdout (URL per line). Duplicates are possible. 
Especially with -b. Use "sort | uniq" to get unique URL output. 
);
	exit(0);
}

package RDFHandler;

use strict;
use Data::Dumper;

my $sbaseurl;

sub new {
    my $type = shift;
    return bless {}, $type;
}

sub sbaseurl {
	$sbaseurl=1;
}


sub start_element {
    my ($self, $element) = @_;
    my $current_element = $element->{Name};

    if ($current_element eq 'ExternalPage') {
	my $link = $element->{Attributes}->{'{}about'}->{'Value'};
	if ($link) {
		if ($sbaseurl) {
			my ($url,$blank,$host,$rest)=split("/",$link);
			print $url."/".$blank."/".$host."/";
		} else {
			print $link;
		}
		print "\n";
	}
    }
}

1;

