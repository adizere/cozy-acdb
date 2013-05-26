package CozyAnonymizer::Lattice;


use strict;
use warnings;


use base 'Class::Accessor::Grouped';

__PACKAGE__->mk_group_accessors(simple => qw( _iname ));


use Data::Dumper;


my $global_lattice = {
	'county' => {
		'0' =>
			sub {
				return $_[0];
			},
		'1' =>
			sub {
				if ($_[0] =~ m/[a-q]/i){
					return "East";
				} else {
					return "West";
				}
			}
	},
	'height' => {
		'0' =>
			sub {
				return $_[0];
			},
		'1' =>
			sub {
				unless ($_[0] =~ m/^\d+$/) {
					return $_[0];
				}
				if ($_[0] < 150){
					return '<150';
				} else {
					return '>=150';
				}
			},
	},
	'sex' => {
		'0' =>
			sub {
				return $_[0];
			},
		'1' =>
			sub {
				return "?";
			}
	}
};

sub new {
	my $pkg = shift();
	my $iname = shift();

	unless ($iname) {
		die "No identifier name was provided!\n";
	}

	my $self = {};
	bless $self, $pkg;

	$self->_iname( $iname );

	# $global_lattice->{$self->_iname()}->{1}( 'JEJEU' );

	return $self;
}


sub get_generalization {
	my $self = shift();
	my $value = shift();
	my $lvl = shift();

	unless ( defined $value) {
		die "No value passed to Lattice\n";
	}

	unless ( defined $lvl) {
		die "No level passed to Lattice\n";
	}

	return $global_lattice->{$self->_iname()}->{$lvl}($value);
}


sub has_level {
	my $self = shift();
	my $lvl = shift();

	if (exists $global_lattice->{$self->_iname()}->{$lvl}){
		return 1;
	}
	return 0;
}

1;