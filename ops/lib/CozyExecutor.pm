package CozyExecutor;

use strict;
use warnings;

use base 'App::Cmdline';

use Data::Dumper;


sub opt_spec {
    my $self = shift;
    return $self->check_for_duplicates (
        [ 'TYPE EXERCISE-NUMBER'],
        [ 'TYPE:             type of the exercise: numerical | boolean | spatial | time'],
        [ 'EXERCISE-NUMBER:  a number from 1-5']
    );
}


sub execute {
    my ($self, $opt, $args) = @_;

    my $type_class = 'CozyExecutor::' . ucfirst(shift @$args);
    my $type_method = 'execute_' . (shift @$args);

    eval "require $type_class";
    if ($@) {
        print Dumper $@;
        print "Invalid TYPE given\n";
        exit;
    }

    my $instance = $type_class->new();
    unless( $instance->can( $type_method ) ) {
        print "Invalid EXERCISE-NUMBER given\n";
    }

    $instance->$type_method($args);
}


1;