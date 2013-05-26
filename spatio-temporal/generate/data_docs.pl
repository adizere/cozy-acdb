#!/usr/bin/perl

use strict;
use warnings;

use CouchDB::Client;
use Math::Random::Secure qw(irand);

use Data::Dumper;

my $c = CouchDB::Client->new(uri => 'http://cozy:5984/');
$c->testConnection or die "The server cannot be reached";

print "Running version " . $c->serverInfo->{version} . "\n";

# DB creation
$c->req('PUT', 'cabd');

foreach my $minute (0..1439) {
	my $sum = 0;

	foreach my $type (qw(rtt bps lpc conc)) {

		# Random between 0 and 100
		my $height = irand(100);
		my $start_height;
		if ($type eq 'rtt') {
			$start_height = 0;
		} else {
			$start_height = $sum;
		}

		my $obj = {
			type => $type,
			state => $minute,
			start_height => $start_height,
			end_height => $start_height + $height,
			total_height => $height,
		};

		# Save the object
		$c->req('POST', 'cabd', $obj);

		$sum += $height;
	}

	# And the last type
	my $height = 400 - $sum;
	my $obj = {
		type => 'itw',
		state => $minute,
		start_height => $sum,
		end_height => 400,
		total_height => $height,
	};
	$c->req('POST', 'cabd', $obj);

	print "$minute / 1400 done\n" if ($minute % 100 == 0);
}