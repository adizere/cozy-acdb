package CozyAnonymizer::Combiner;


use strict;
use warnings;


use Data::Dumper;

use CozyClient;
use Math::Combinatorics;
use Clone qw(clone);



sub new {
	my $pkg = shift();

	my $self = {};
	bless $self, $pkg;

	return $self;
}


sub add_identifiers {
	my $self = shift();
	my @ids = @_;

	$self->{_attributes} = [];

	foreach(@ids) {
		$self->{identifiers}->{$_->iname()} = $_;
		push @{$self->{_attributes}}, $_->iname();
	}
}


sub get_combinations {
	my $self = shift();
	my @candidates = @{shift()};
	my $level = shift();

	my @result = ();

	# We'll construct combinations of size $level

	my @attributes = $self->_get_attributes();
	my @r_combi = combine($level, @attributes);

	foreach(@r_combi) {
		# extract a pair of N-attributes
		my $current = $self->_extract_candidate( $_, @candidates );

		printf("\tCurrent candidate: %s\n",
			join '; ', map {$_ . ": " . $current->{$_} } sort keys %$current );

		my $valid = $self->_validate_candidate($current);

		if ($valid) {
			printf("* Valid candidate found: %s\n",
				join '; ', map {$_ . ": " . $current->{$_} } sort keys %$current);
			push @result, $current;
		} else {
			my @others = $self->_expand_candidate($current);
			foreach my $othcand (@others){
				# printf("--Checking others....\n");
				my $othvalid = $self->_validate_candidate($othcand);
				if ($othvalid) {
					printf("* Valid candidate found: %s\n",
						join '; ', map {$_ . ": " . $othcand->{$_} } sort keys %$othcand);
					push @result, $othcand;
				}
			}
		}
	}

	return @result;
}


sub _get_attributes {
	my $self = shift();

	return @{$self->{_attributes}};
}


sub _extract_candidate {
	my $self = shift();
	my @what = @{shift()};
	my @candidates = @_;

	my $ret = {};

	if (scalar @what > 2) {
		# splitting the attributes

		my $split = {};
		foreach my $ccand (@candidates) {
			foreach my $cattr (keys %$ccand) {
				$split->{$cattr}->{$ccand->{$cattr}} = 1;
			}
		}

		# there are three levels of iterativity
		foreach my $county(keys $split->{county}) {
			foreach my $height (keys $split->{height}) {

				# validate this pair
				my $fl = 0;
				foreach my $ccand (@candidates) {
					if ( exists $ccand->{county} && ( $ccand->{county} <= $county )
						&& exists $ccand->{height} && ( $ccand->{height} <= $height ) ) {
							$fl = 1;
							last;
					}
				}
				next unless ($fl);

				foreach my $sex (keys $split->{sex}) {

					# validate county+sex
					my $cs_fl = 0;
					foreach my $ccand (@candidates) {
						if ( exists $ccand->{county} && ( $ccand->{county} <= $county )
							&& exists $ccand->{sex} && ( $ccand->{sex} <= $sex ) ) {
								$cs_fl = 1;
								last;
						}
					}
					next unless ($cs_fl);

					# validate height+sex
					my $hs_fl = 0;
					foreach my $ccand (@candidates) {
						if ( exists $ccand->{height} && ( $ccand->{height} <= $height )
							&& exists $ccand->{sex} && ( $ccand->{sex} <= $sex ) ) {
								$hs_fl = 1;
								last;
						}
					}
					next unless ($hs_fl);

					$ret->{county} = $county;
					$ret->{height} = $height;
					$ret->{sex} = $sex;
				}
			}
		}

	} else {
		foreach my $ccand (@candidates) {
			foreach my $attr (@what) {
				if ( exists $ccand->{$attr} ) {
					$ret->{$attr} = $ccand->{$attr};
				}
			}
		}
	}

	return $ret;
}


# is 2-anonimity respected?
sub _validate_candidate {
	my $self = shift();
	my $cand = shift();

	my $transform_result = [];

	foreach(sort keys $cand){
		$transform_result =
			$self->_apply_single_generalization($_, $cand->{$_}, $transform_result);

		my $c = 0;
		# printf("Single generalization result:\n%s",
		# 		join '', map {
		# 		sprintf("%s-%s-%s\n",
		# 			$_->{value}->{county}, $_->{value}->{height}, $_->{value}->{sex} )
		# 		if ($c++<10); } @$transform_result );
	}

	my $ancheck = $self->_check_anonymity($transform_result, keys $cand);

	# printf("Valid: %s\n", $ancheck ? "true" : "false");
	return $ancheck;
}


sub _apply_single_generalization {
	my $self = shift();
	my $what = shift();
	my $lvl = shift();

	my $so_far = shift();

	my @res;
	unless (scalar @$so_far) {
		@res = $self->{identifiers}->{$what}->get_all_clean();
		$so_far = \@res;
	}

	my $gen = $self->{identifiers}->{$what}->apply_generalization($lvl, $so_far);

	return $gen;
}


sub _check_anonymity {
	my $self = shift();
	my $target = shift();
	my @keys = @_;

	my $check = {};

	foreach my $current( @$target ) {
		my $key =
			join '', map {$current->{value}->{$_}} @keys;

		if ( exists $check->{$key}) {
			$check->{$key}++;
		} else {
			$check->{$key} = 1;
		}
	}

	# print Dumper $check;

	foreach( keys %$check ){
		if ($check->{$_} < 2) {
			return 0;
		}
	}

	return 1;
}


sub _expand_candidate {
	my $self = shift();
	my $cand = shift();

	my @exps = ();

	foreach( keys %$cand ) {
		my $current_lvl = $cand->{$_};
		if ($self->{identifiers}->{$_}->can_level($current_lvl+1)) {
			my $expanded = clone($cand);
			$expanded->{$_} = $current_lvl+1;
			push @exps, $expanded;
		}
	}

	# printf("Initial candidate: %s; expanded: %s", Dumper( $cand ), Dumper( \@exps ));

	return @exps;
}

1;