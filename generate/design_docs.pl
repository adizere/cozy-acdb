#!/usr/bin/perl

use strict;
use warnings;

use CouchDB::Client;
use Math::Random::Secure qw(irand);

use Data::Dumper;

my $c = CouchDB::Client->new(uri => 'http://cozy:5984/');
$c->testConnection or die "The server cannot be reached";

print "Running version " . $c->serverInfo->{version} . "\n";


foreach(qw( rtt bps lpc conc itw)) {
	my $obj = {
	   "views" => {
	       "all" => {
	           "map" =>
	           		"function(doc) {
						var key, value;
						if (doc.type == '$_') {
						   value = doc;
						   key = doc.state;
						   emit(key, value);
						}
	            	}"
	       }
	   }
	};
	my $res = $c->req('PUT', "cabd/_design/$_", $obj);
}