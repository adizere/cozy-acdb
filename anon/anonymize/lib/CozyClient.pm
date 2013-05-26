package CozyClient;

use strict;
use warnings;

use DB::CouchDB;
use Data::Dumper;


sub new {
	my $package = shift();
	my $self = {};

	$self->{db} = DB::CouchDB->new(host => 'cozy', db   => 'anon');

	bless $self, $package;

	return $self;
}


sub run {
	my ( $self, $method, $args, $sargs ) = @_;

	return $self->{db}->$method( $args, $sargs );
}


sub fetch_single {
	my ( $self, $type, $instance ) = @_;

	my $view_args = {
		key => $instance,
	};

	my $object = $self->run( 'view', "$type/_view/all", $view_args)->data;
	unless( $object && $object->[0] ){
		print "Instance $instance not found for $type\n";
		exit;
	}
	$object = $object->[0];

	return $object;
}


sub fetch_interval {
	my ( $self, $type, $start, $end ) = @_;

	my $view_args = {
		startkey => $start,
		endkey => $end,
	};

	my $list = $self->run( 'view', "$type/_view/all", $view_args)->data;
	unless( $list && $list->[0] ){
		print "No instance found between $start and $end for $type\n";
		exit;
	}

	return @$list;
}


sub fetch_all {
	my ( $self, $type ) = @_;

	my $list = $self->run( 'view', "$type/_view/all")->data;
	unless( $list && $list->[0] ){
		print "No instance found for $type\n";
		exit;
	}

	return @$list;
}


sub update {
	my $self = shift();
	my $id = shift();
	my $value = shift();

	my $res = $self->run('update_doc', $id, $value);
}

1;