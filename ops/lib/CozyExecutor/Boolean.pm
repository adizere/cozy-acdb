package CozyExecutor::Boolean;

use strict;
use warnings;

use CozyClient;

use Object::New;
use Data::Dumper;



sub execute_1 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance > 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $client = CozyClient->new();

	my $rtt = $client->fetch_single( 'rtt', $instance );
	my $bps = $client->fetch_single( 'bps', $instance );


	my $result = $bps->{value}->{total_height} == $rtt->{value}->{total_height} ?
		'true' : 'false';

	print "Equality between rtt and bps in instance $instance: $result\n";
}

sub execute_2 {
	my $self = shift();
	my $args = shift();

	my $start = shift @$args;
	unless ( defined $start && ($start >= 0 && $start < 1440)){
		print "Invalid start requested $start\n";
		exit;
	}

	my $end = shift @$args;
	unless ( defined $end && ($end >= 0 && $end < 1440)){
		print "Invalid end requested $end\n";
		exit;
	}

	my $result = abs( $start - $end );
	if ( $result == 1 ) {
		$result = 'true';
	} else {
		$result = 'false';
	}

	print "Adjacency of two intervals of time ($start, $end): $result\n";
}

sub execute_3 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance >= 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $point_x = shift @$args;
	unless (defined $point_x ){
		print "The coordinates for the point were not given\n";
		exit;
	}

	my $point_y = shift @$args;
	unless (defined $point_y ){
		print "The coordinate Y for the point was not given\n";
		exit;
	}

	my $client = CozyClient->new();

	my $conc = $client->fetch_single( 'conc', $instance );

	# Calculating the perimeter
	# the rectangle will be between:
	# upper left: 0, end_height
	# lower right: 10, start_height

	my $result = 'false';
	if 	(
			$point_x <= 10 &&
			$point_x >= 0 &&
			$point_y <= $conc->{value}->{end_height} &&
			$point_y >= $conc->{value}->{start_height}
		){
		$result = 'true';
	}

	print "Membership of point ($point_x, $point_y) inside conc rectangle in " .
		"instance $instance: $result
		[conc is placed between " . $conc->{value}->{start_height} . " and " .
		$conc->{value}->{end_height} . "]\n";
}

sub execute_4 {
	my $self = shift();
	my $args = shift();

	my $start = shift @$args;
	unless ( defined $start && ($start >= 0 && $start < 1440)){
		print "Invalid instance requested $start\n";
		exit;
	}

	my $end = shift @$args;
	unless ( defined $end && ($end >= 0 && $end < 1440)){
		print "Invalid instance requested $end\n";
		exit;
	}

	my $point_x = shift @$args;
	unless (defined $point_x ){
		print "The coordinates for the point were not given\n";
		exit;
	}

	my $point_y = shift @$args;
	unless (defined $point_y ){
		print "The coordinate Y for the point was not given\n";
		exit;
	}

	my $client = CozyClient->new();

	my @bpss = $client->fetch_interval( 'bps', $start, $end );

	my $result = 'false';

	foreach(@bpss){
		if 	(
				$point_x <= 10 &&
				$point_x >= 0 &&
				$point_y <= $_->{value}->{end_height} &&
				$point_y >= $_->{value}->{start_height}
			){
			$result = 'true';
			# last;
		}
		print "\t location: [" . $_->{value}->{start_height} . ", " .
			 $_->{value}->{end_height} . "]\n";
	}

	print "Membership of a point ($point_x, $point_y) inside bps rectangle
		in an intervalbetween moments $start and $end: $result\n";
}

sub execute_5 {
	my $self = shift();
	my $args = shift();

	my $start = shift @$args;
	unless ( defined $start && ($start >= 0 && $start < 1440)){
		print "Invalid instance requested $start\n";
		exit;
	}

	my $end = shift @$args;
	unless ( defined $end && ($end >= 0 && $end < 1440)){
		print "Invalid instance requested $end\n";
		exit;
	}

	my $expected_height = shift @$args;
	unless (defined $expected_height ){
		print "The expected_height for the point was not given\n";
		exit;
	}

	my $client = CozyClient->new();

	my @lpc_states = $client->fetch_interval( 'lpc', $start, $end );

	my $max = 0;
	my $pos = $start;

	foreach(@lpc_states){
		if ($_->{value}->{end_height} > $max) {
			$max = $_->{value}->{end_height};
			$pos = $_->{value}->{state};
		}
		# print $_->{value}->{state} . ": " . $_->{value}->{total_height} . "\n";
	}

	my $result = ($expected_height == $max ? 'true' : 'false' );

	print "Southern-most point of lpc rectangle in the interval $start, $end
		is expected to be at $expected_height: $result
		[hint: $max]\n";
}


1;