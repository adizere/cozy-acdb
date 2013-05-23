#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use CGI;

use CozyClient;

use Data::Dumper;

my $q = CGI->new;
print $q->header('application/json');


my $start = $q->param('start');
my $end = $q->param('end');

warn "Serving: $start -> $end\n";

my $res = {};

my $client = CozyClient->new();

foreach my $type (qw(rtt bps lpc conc itw)) {
    my @instances = $client->fetch_interval( $type, $start, $end );

    foreach my $cs (@instances) {
        $res->{$cs->{value}->{state}}->{$type} = {
            start_height    => $cs->{value}->{start_height},
            end_height      => $cs->{value}->{end_height},
        };
    }
}

my $jsref = encode_json $res;

print $jsref;
exit;