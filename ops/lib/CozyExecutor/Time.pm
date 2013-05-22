package CozyExecutor::Time;

use strict;
use warnings;

use CozyClient;

use Object::New;
use Data::Dumper;



sub execute_1 {
	my $self = shift();
	my $args = shift();

	my $client = CozyClient->new();

	my @bps_states = $client->fetch_all( 'bps' );

	my $max = 0;
	my $pos = 0;

	foreach(@bps_states){
		if ($_->{value}->{total_height} >= $max) {
			$max = $_->{value}->{total_height};
			$pos = $_->{value}->{state};
		}
		# print $_->{value}->{state} . " " . $_->{value}->{total_height} . "\n";
	}

	print "Rectangle for BPS had the maximum value of $max in state $pos\n";
}

sub execute_2 {
	my $self = shift();
	my $args = shift();

	my $client = CozyClient->new();

	my @itw_states = $client->fetch_all( 'itw' );
	my @lpc_states = $client->fetch_all( 'lpc' );


	my $found = 0;
	my @states = ();
	my $c = 0;
	while (1) {

		my $lpc_state = shift @itw_states;
		my $rtt_state = shift @lpc_states;

		my $lpc = $lpc_state->{value}->{total_height};
		my $rtt = $rtt_state->{value}->{total_height};

		# print qq|$c: $lpc ; $rtt \n|;

		if ($lpc > $rtt) {
			$found = 1;
			push @states, $c;
		} elsif ($found == 1){
			last;
		}

		$c++;
		last if ( scalar @lpc_states == 0);
	}

	print "The first interval of time when ITW rectangle was detected greater
	than the LPC rectangle is composed of states: \n" .
	join(', ', @states) . "\n";
}

sub execute_3 {
	my $self = shift();
	my $args = shift();

	my $client = CozyClient->new();

	my @conc_states = $client->fetch_all( 'conc' );

	my $max = {
		length => 0,
		start => 0,
		end => 0,
	};
	my $last = {
		length => 0,
		start => 0,
		end => 0,
	};
	my $counting = 0;

	foreach(@conc_states){
		if ($_->{value}->{total_height} >= 50) {
			if ($counting) {
				# continue counting
				$last->{length}++;
			} else {
				# print $_->{value}->{state} . " start\n";
				# start counting
				$counting = 1;
				$last->{length} = 1;
				$last->{start} = $_->{value}->{state};
			}
		} else {
			if ($counting == 1) {
				# print $_->{value}->{state} . " stop\n";
				# stop counting
				$counting = 0;
				$last->{end} = $_->{value}->{state} - 1;

				if ($last->{length} >= $max->{length}){
					# print $_->{value}->{state} . " replace\n";
					foreach(qw(length start end)){
						$max->{$_} = $last->{$_};
					}
				}
				$last->{length} = $last->{start} = $last->{end} = 0;
			}
		}
	}

	print qq|Longest interval of time when CONC rectangle has height >= 50 is
	of length $max->{length} and is between states $max->{start}:$max->{end}\n|;
}


1;