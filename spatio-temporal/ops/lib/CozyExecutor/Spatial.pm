package CozyExecutor::Spatial;

use strict;
use warnings;

use CozyClient;

use Object::New;
use Set::Intersection;
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

	# print Dumper $rtt;
	# print Dumper $bps;

	my $fstart_x = $rtt->{value}->{start_height};
	my $fstart_y = 0;

	my $fend_y = $bps->{value}->{end_height};
	my $fend_x = 10;

	print "The fusion of the rectangles of RTT and BPS would yield another " .
		"rectangle of width 10 and height $fend_y;
		lower left bound ($fstart_x, $fstart_y);
		upper right bound ($fend_x, $fend_y)\n";
}

sub execute_2 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance >= 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $minx = shift @$args;
	unless ( defined $minx && $minx >= 0 && $minx <= 10 ){
		print "Invalid minx requested $minx\n";
		exit;
	}
	my $miny = shift @$args;
	unless ( defined $miny && $miny >= 0 && $miny <= 400){
		print "Invalid miny requested $miny\n";
		exit;
	}

	my $maxx = shift @$args;
	unless ( defined $maxx && $maxx >= 0 && $maxx <= 10){
		print "Invalid maxx requested $maxx\n";
		exit;
	}
	unless( $maxx >= $minx ) {
		print "Max X should not be smaller than Min X\n";
		exit;
	}
	my $maxy = shift @$args;
	unless ( defined $maxy && $maxy >= 0 && $maxy <= 400){
		print "Invalid maxy requested $maxy\n";
		exit;
	}
	unless ($maxy >= $miny) {
		print "Max Y should not be smaller than Min Y\n";
		exit;
	}

	my $clip_mask = {
		min_x => $minx,
		min_y => $miny,
		max_x => $maxx,
		max_y => $maxy,
	};
	my @clip_height = $miny .. $maxy;
	# print "Clip mask height: " . Dumper \@clip_height;

	my $client = CozyClient->new();

	# Let the clipping begin

	# Get all the possible types and compute which are contained
	my @contains = ();
	foreach my $type (qw(rtt bps lpc conc itw)) {
		my $cstate = $client->fetch_single( $type, $instance );
		# print Dumper $cstate;

		my @target_height = $cstate->{value}->{start_height} .. $cstate->{value}->{end_height};
		# print "Target Height: " . Dumper \@target_height;

		my @inter = sort {$a <=> $b} get_intersection(\@clip_height, \@target_height);
		if (scalar @inter){
			push @contains, {
				type => $type,
				from => shift @inter,
				to => pop @inter,
				hint => $cstate->{value}->{start_height} . ":" . $cstate->{value}->{end_height},
			};
			$contains[$#contains]->{to} = $contains[$#contains]->{from} unless $contains[$#contains]->{to};
		}
	}

	print "Clipping of instance $instance with the mask:
	($minx, $miny), ($maxx, $maxy)
will yield the rectangles: \n";
	foreach(@contains){
		print qq|\t$_->{type}: with bounds: ($minx, $_->{from}), ($maxx, $_->{to})\n|;
		print qq|\t\t[hint: $_->{type} bounded between $_->{hint}]\n|;
	}
}

sub execute_3 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance >= 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $client = CozyClient->new();

	my $lpc = $client->fetch_single( 'lpc', $instance );
	my $target_low = $lpc->{value}->{start_height},
	my $target_up = $lpc->{value}->{end_height},

	my @neighbours = ();
	foreach my $type (qw(rtt bps conc itw)) {
		my $candidate = $client->fetch_single( $type, $instance );

		if ($target_low == $candidate->{value}->{end_height}) {
			push @neighbours, {
				type => uc $type,
				where => 'lower',
				hint => $candidate->{value}->{start_height} . ":" . $candidate->{value}->{end_height},
			};
		} elsif ($target_up == $candidate->{value}->{start_height}) {
			push @neighbours, {
				type => uc $type,
				where => 'upper',
				hint => $candidate->{value}->{start_height} . ":" . $candidate->{value}->{end_height},
			};
		}
	}

	print "The neighbours of LPC in instance $instance are:\n";
	foreach(@neighbours) {
		print qq|\t$_->{type} in the $_->{where} limit\n|;
		print qq|\t\t[hint: $_->{type} is between $_->{hint}]\n|;
	}
}

sub execute_4 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance >= 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $minx = shift @$args;
	unless ( defined $minx && $minx >= 0 && $minx <= 10 ){
		print "Invalid minx requested $minx\n";
		exit;
	}
	my $miny = shift @$args;
	unless ( defined $miny && $miny >= 0 && $miny <= 400){
		print "Invalid miny requested $miny\n";
		exit;
	}

	my $maxx = shift @$args;
	unless ( defined $maxx && $maxx >= 0 && $maxx <= 10){
		print "Invalid maxx requested $maxx\n";
		exit;
	}
	unless( $maxx >= $minx ) {
		print "Max X should not be smaller than Min X\n";
		exit;
	}
	my $maxy = shift @$args;
	unless ( defined $maxy && $maxy >= 0 && $maxy <= 400){
		print "Invalid maxy requested $maxy\n";
		exit;
	}
	unless ($maxy >= $miny) {
		print "Max Y should not be smaller than Min Y\n";
		exit;
	}

	my @clip_height = $miny .. $maxy;

	my $client = CozyClient->new();

	# Let the clipping begin

	# Get all the possible types and compute which are superimposed
	my @superi = ();
	my @unch = ();
	foreach my $type (qw(rtt bps lpc conc itw)) {
		my $cstate = $client->fetch_single( $type, $instance );
		# print Dumper $cstate;

		my @target_height = $cstate->{value}->{start_height} .. $cstate->{value}->{end_height};

		my @inter = sort {$a <=> $b} get_intersection(\@clip_height, \@target_height);
		if (scalar @inter){
			push @superi, {
				type => $type,
				from => $inter[0],
				to => pop @inter,
				hint => $cstate->{value}->{start_height} . ":" . $cstate->{value}->{end_height},
			};
			$superi[$#superi]->{to} = $superi[$#superi]->{from} unless $superi[$#superi]->{to};
		} else {
			push @unch, $type;
		}
	}

	print "Superimposion over instance $instance with the mask:
	($minx, $miny), ($maxx, $maxy)
	would intersect and cover the rectangles: \n";
	foreach(@superi){
		print qq|\t$_->{type}: with bounds: ($minx, $_->{from}), ($maxx, $_->{to})\n|;
		print qq|\t\t[hint: $_->{type} bounded between $_->{hint}]\n|;
	}
	if (scalar @unch) {
		print "The following rectangles are unchanged: " . join(',', @unch) . "\n";
	}
}

sub execute_5 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance >= 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $client = CozyClient->new();

	my $cover = {};
	foreach my $type (qw(rtt bps lpc conc itw)) {
		my $cstate = $client->fetch_single( $type, $instance );

		my $start = $cstate->{value}->{start_height};
		my $end = $cstate->{value}->{end_height};

		$cover->{$start}->{starts} = $cover->{$end}->{ends} = $type;
	}

	print "Cover result for instance $instance:\n";
	foreach(sort {$a <=> $b} keys %$cover) {
		print "In point $_: \n";
		print "\t ends: " . $cover->{$_}->{ends} . "\n" if exists ($cover->{$_}->{ends});
		print "\t starts: " . $cover->{$_}->{starts} . "\n" if exists ($cover->{$_}->{starts});
	}
}


1;