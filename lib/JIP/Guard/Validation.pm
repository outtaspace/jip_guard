package JIP::Guard::Validation;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

use JIP::Guard::Factory::Checks;
use JIP::Guard::ValidationError;

our $VERSION = '0.01';

has [qw(document schema registry error_handler)] => (get => q{+}, set => q{-});

sub new {
    my ($class, %param) = @ARG;

    # Mandatory params
    croak q{Mandatory argument "document" is missing}
        unless exists $param{'document'};

    croak q{Mandatory argument "schema" is missing}
        unless exists $param{'schema'};

    croak q{Mandatory argument "registry" is missing}
        unless exists $param{'registry'};

    croak q{Mandatory argument "error_handler" is missing}
        unless exists $param{'error_handler'};

    return bless({}, $class)
        ->_set_document($param{'document'})
        ->_set_schema($param{'schema'})
        ->_set_registry($param{'registry'})
        ->_set_error_handler($param{'error_handler'});
}

sub validate {
    my $self = shift;

    return $self->_set_up->_check->_tear_down;
}

sub record_error {
    my ($self, %param) = @ARG;

    my $error = JIP::Guard::ValidationError->new(%param);

    $self->error_handler->add($error);

    return $self;
}

sub _set_up {
    my $self = shift;

    $self->error_handler->start;

    return $self;
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

sub _tear_down {
    my $self = shift;

    $self->error_handler->end;

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

