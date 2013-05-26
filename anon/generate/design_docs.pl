#!/usr/bin/perl

use strict;
use warnings;

use CouchDB::Client;
use Math::Random::Secure qw(irand);

use Data::Dumper;

use constant {
	DB_NAME => 'anon',
};

my $c = CouchDB::Client->new(uri => 'http://cozy:5984/');
$c->testConnection or die "The server cannot be reached";

print "Running version " . $c->serverInfo->{version} . "\n";

my $obj = {
   "views" => {
       "all" => {
           "map" =>
           		"function(doc) {
					var key, value;
				   	value = doc;
				   	key = doc._id;
				   	emit(key, value);
            	}"
       }
   }
};
my $res = $c->req('PUT', DB_NAME . "/_design/tuples", $obj);
print "New [anon] DB design doc status: " . $res->{msg} . "\n";