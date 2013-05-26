#!/usr/bin/perl


use strict;
use warnings;

use Data::Dumper;


use CozyAnonymizer;
use CozyAnonymizer::Identifier;
use CozyAnonymizer::Combiner;


my $height_id = CozyAnonymizer::Identifier->new( 'height' );
my $county_id = CozyAnonymizer::Identifier->new( 'county' );
my $sex_id = CozyAnonymizer::Identifier->new( 'sex' );


my $combiner = CozyAnonymizer::Combiner->new();
$combiner->add_identifiers(
		$height_id, $county_id, $sex_id
	);
my @candidates = (
		{ 'height' => 0 },
		{ 'county' => 0 },
		{ 'sex' => 0 },
	);

# print Dumper $combiner;

for (my $i = 1; $i <= 3; $i++) {
	my @poss = $combiner->get_combinations(\@candidates, $i);
	@candidates = @poss;
}

foreach my $cand (@candidates) {
	my $sum = 0;
	map {$sum += $cand->{$_}} keys $cand;
	next unless ($sum > 0);

	my $anon = CozyAnonymizer->new();
	$anon->add_identifiers(
			$height_id, $county_id, $sex_id
		);
	$anon->anonymize($candidates[0]);
}