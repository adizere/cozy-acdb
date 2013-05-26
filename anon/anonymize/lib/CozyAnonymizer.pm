package CozyAnonymizer;

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


sub anonymize {
	my $self = shift();
	my $params = shift();

	printf("\nAnonymizing the attributes: %s\n",
		join '; ', map {$_ . ": " . $params->{$_} } sort keys %$params);

	foreach my $attr_key(sort keys %$params) {
		my @all = $self->{identifiers}->{$attr_key}->get_all_clean();

		my $gen = $self->{identifiers}->{$attr_key}->apply_generalization(
					$params->{$attr_key},
					\@all );

		$self->{identifiers}->{$attr_key}->update_all($gen);
	}
}


1;