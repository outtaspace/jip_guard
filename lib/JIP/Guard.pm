package JIP::Guard;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

use JIP::Guard::BaseErrorHandler;
use JIP::Guard::Factory::Validation;

our $VERSION = '0.01';

has [qw(purge_unknown allow_unknown)] => (get => q{+}, set => q{+});

has [qw(registry error_handler)] => (get => q{+}, set => q{-});

sub new {
    my ($class, %param) = @ARG;

    # Mandatory params
    croak q{Mandatory argument "registry" is missing}
        unless exists $param{'registry'};

    # Optional params
    my $purge_unknown = 0;
    if (exists $param{'purge_unknown'}) {
        $purge_unknown = $param{'purge_unknown'} ? 1 : 0;
    }

    my $allow_unknown = 1;
    if (exists $param{'allow_unknown'}) {
        $allow_unknown = $param{'allow_unknown'} ? 1 : 0;
    }

    my $error_handler;
    if (exists $param{'error_handler'}) {
        $error_handler = $param{'error_handler'};
    }
    else {
        $error_handler = JIP::Guard::BaseErrorHandler->new;
    }

    return bless({}, $class)
        ->_set_registry($param{'registry'})
        ->_set_error_handler($error_handler)
        ->set_purge_unknown($purge_unknown)
        ->set_allow_unknown($allow_unknown);
}

sub validate {
    my ($self, %param) = @ARG;

    my $validation = JIP::Guard::Factory::Validation->create_for_request(
        %param,
        registry      => $self->registry,
        error_handler => $self->error_handler,
    );

    $validation->validate;

    return $validation->error_handler->has_error ? 0 : 1;
}

sub errors {
    my $self = shift;

    return $self->error_handler->errors;
}

sub has_error {
    my $self = shift;

    return $self->error_handler->has_error;
}

1;

