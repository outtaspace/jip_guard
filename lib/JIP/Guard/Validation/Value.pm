package JIP::Guard::Validation::Value;

use parent 'JIP::Guard::Validation';

use strict;
use warnings;

use Carp qw(croak);
use English qw(-no_match_vars);

use JIP::Guard::Factory::Checks;

our $VERSION = '0.01';

sub validate {
    my $self = shift;

    return $self->_set_up->_check->_tear_down;
}

sub _check {
    my $self = shift;

    my $definitions = $self->registry->get($self->schema); # entry point

    croak(sprintf 'No definitions found for "%s"', $self->schema)
        unless $definitions;

    my $checks = $self->_create_checks_for($definitions);

    for my $each_definition ($definitions->build_check_sequence) {
        my $need_to_continue = do {
            my $method = $each_definition->method;

            $checks->$method($each_definition);
        };

        last unless $need_to_continue;
    }

    return $self;
}

sub _create_checks_for {
    my ($self, $definitions) = @ARG;

    return JIP::Guard::Factory::Checks->create_for_definitions_instance(
        definitions => $definitions,
        validation  => $self,
    );
}

1;

