#!/usr/bin/perl

use strict;
use warnings;

use CouchDB::Client;
use Math::Random::Secure qw(irand);

use Data::Dumper;

my $c = CouchDB::Client->new(uri => 'http://cozy:5984/');
$c->testConnection or die "The server cannot be reached";

print "Running version " . $c->serverInfo->{version} . "\n";

print Dumper $c->listDBNames;


my $obj = {
	company => 'a',
	this => 'that'
};
$c->req('POST', 'cabd', $obj);

foreach my $minute (0..1440) {
	my $sum = 0;

	foreach my $type (qw(rtt bps lpc conc)) {
		my $obj = {
			type => $type,
			state => $minute,
			height => irand(1439) + 1,
		}
	}
}