package CozyAnonymizer::Identifier;

# A Quasi-Identifier


use strict;
use warnings;

use Data::Dumper;
use Clone qw(clone);

use base 'Class::Accessor::Grouped';

__PACKAGE__->mk_group_accessors(simple => qw( iname _dbh _lattice ));

use CozyClient;
use CozyAnonymizer::Lattice;

sub new {
	my $pkg = shift();
	my $iname = shift();

	unless ($iname) {
		die "No identifier name was provided!\n";
	}

	my $self = {};
	bless $self, $pkg;

	$self->iname( $iname );

	$self->_dbh( CozyClient->new() );
	$self->_lattice( CozyAnonymizer::Lattice->new( $iname ) );

	return $self;
}


sub get_all_clean {
	my $self = shift();

	return $self->_dbh()->fetch_all( 'tuples' );
}

sub can_level {
	my $self = shift();
	my $lvl = shift();

	# printf("Checking level %s for %s\n", $lvl, $self->iname());

	return $self->_lattice()->has_level($lvl);
}


sub apply_generalization {
	my $self = shift();
	my $lvl = shift();
	my $target_data = shift();

	my $result = clone($target_data);

	# printf("Applying generalization on attr %s, lvl %s\n", $self->iname(), $lvl );
	# my $c = 0;
	# printf("Target data:\n%s",
	# 		join '', map {
	# 		sprintf("%s-%s-%s\n",
	# 			$_->{value}->{county}, $_->{value}->{height}, $_->{value}->{sex} )
	# 		if ($c++<10); } @$result );

	foreach my $index( 0 .. scalar( @$result ) - 1 ) {
		my $attribute = $result->[$index]->{value}->{$self->iname()};

		my $updated = $self->_lattice()->get_generalization( $attribute, $lvl );
		# printf("Generalization result: %s -> %s\n", $attribute, $updated)
		# 	if ( $lvl > 0 );

		$result->[$index]->{value}->{$self->iname()} = $updated;
	}

	# print "Gen result: " . "---"x10 . "\n";
	# $c = 0;
	# printf("Target data:\n%s",
	# 		join '', map {
	# 		sprintf("%s-%s-%s\n",
	# 			$_->{value}->{county}, $_->{value}->{height}, $_->{value}->{sex} )
	# 		if ($c++<10); } @$result );

	return $result;
}


sub update_all {
	my $self = shift();
	my $data = shift();


	foreach my $next (@$data) {
		$self->_dbh()->update($next->{id}, $next->{value});
	}
}

1;