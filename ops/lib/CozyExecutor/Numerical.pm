package CozyExecutor::Numerical;

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
	my $lpc = $client->fetch_single( 'lpc', $instance );

	my $result = $lpc->{value}->{start_height} - $rtt->{value}->{end_height};

	print "Distance between RTT and LPC in instance $instance is: $result\n";
}

sub execute_2 {
	my $self = shift();
	my $args = shift();

	my $instance = shift @$args;
	unless ( defined $instance && ($instance >= 0 && $instance < 1440)){
		print "Invalid instance requested $instance\n";
		exit;
	}

	my $client = CozyClient->new();

	my $rtt = $client->fetch_single( 'rtt', $instance );

	# Calculating the perimeter
	my $p = 2*10 + 2*($rtt->{value}->{total_height});

	print "The perimeter of RTT rectangle in state $instance is: $p\n";
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

	my $conc = $client->fetch_single( 'conc', $instance );

	# Calculating the perimeter
	my $area = 10*($conc->{value}->{total_height});

	print "The area of CONC rectangle in state $instance is: $area\n";
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

	my $client = CozyClient->new();

	my @concs = $client->fetch_interval( 'conc', $start, $end );

	my $changed = 0;
	my $states = {};

	foreach(@concs){
		unless( exists $states->{$_->{value}->{total_height}} ){
			$states->{$_->{value}->{total_height}} = 1;
			$changed++;
		}
		# print $_->{value}->{state} . ": " . $_->{value}->{total_height} . "\n";
	}

	print "CONC rectangle passed through $changed states between moments $start and $end\n";
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

	my $client = CozyClient->new();

	my @bps_states = $client->fetch_interval( 'bps', $start, $end );

	my $max = 0;
	my $pos = $start;

	foreach(@bps_states){
		if ($_->{value}->{total_height} > $max) {
			$max = $_->{value}->{total_height};
			$pos = $_->{value}->{state};
		}
		# print $_->{value}->{state} . ": " . $_->{value}->{total_height} . "\n";
	}

	print "Maximum distance between rectangles RTT and LPC from states $start\
	 through $end is at $pos, with value $max\n";
}


1;