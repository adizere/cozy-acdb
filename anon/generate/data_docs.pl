#!/usr/bin/perl

use strict;
use warnings;

use CouchDB::Client;
use Math::Random::Secure qw(irand);

use Data::Dumper;

use constant {
	DB_NAME => 'anon',
	TUPLES => 100,
};


my $c = CouchDB::Client->new(uri => 'http://cozy:5984/');
$c->testConnection or die "The server cannot be reached";

print "Running version " . $c->serverInfo->{version} . "\n";

my $res = $c->req('GET', DB_NAME);
unless( $res->{success} ){
	# DB creation
	$res = $c->req('PUT', 'anon');
}

print "New [anon] DB creation status: " . $res->{msg} . "\n";

my @counties = ('A'..'Z');
my @sexes = ('M', 'F');

foreach my $tuple (1..TUPLES) {

	# Random between 0 and 100
	my ( $height_index, $county_index, $sex_index, $has_dog )
	 = ( irand(20), irand(scalar @counties), irand(2), irand(2));

	my $obj = {
		height => 140 + $height_index,
		county => $counties[$county_index],
		sex => $sexes[$sex_index],
		dog => $has_dog,
	};

	# 	# Save the object
	$c->req('POST', DB_NAME, $obj);

	print "$tuple /" . TUPLES . " done\n" if ($tuple % 10 == 0);
}