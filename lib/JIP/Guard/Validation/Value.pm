package JIP::Guard::Validation::Value;

use parent 'JIP::Guard::Validation';

use strict;
use warnings;

use List::MoreUtils qw(any);
use Scalar::Util qw(reftype);
use English qw(-no_match_vars);

use JIP::Guard::Factory::Checks;

our $VERSION = '0.01';

sub validate {
    my $self = shift;

    $self->_set_up;
    $self->_check;
    $self->_tear_down;

    return $self;
}

sub _check {
    my $self = shift;


    my $definitions = $self->registry->get($self->schema); # entry point

    my $checks = JIP::Guard::Factory::Checks->create_for_definitions_instance(
        definitions => $definitions,
        validation  => $self,
    );

    for my $each_definition ($definitions->build_check_sequence) {
        my $need_to_continue = do {
            my $method = $each_definition->method;

            $checks->$method($each_definition);
        };

        last unless $need_to_continue;
    }
}

1;

