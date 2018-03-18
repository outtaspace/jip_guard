package JIP::Guard;

use strict;
use warnings;

use JIP::ClassField;
use Devel::StackTrace;
use Carp qw(croak);
use English qw(-no_match_vars);

use JIP::Guard::Validation;
use JIP::Guard::BaseErrorHandler;

our $VERSION = '0.01';

has [qw(purge_unknown allow_unknown throwable)] => (get => q{+}, set => q{+});

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

    my $throwable = 0;
    if (exists $param{'throwable'}) {
        $throwable = $param{'throwable'} ? 1 : 0;
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
        ->set_allow_unknown($allow_unknown)
        ->set_throwable($throwable);
}

sub validate {
    my ($self, %param) = @ARG;

    my $validation = JIP::Guard::Validation->new(
        document      => $param{'document'},
        schema        => $param{'schema'},
        registry      => $self->registry,
        error_handler => $self->error_handler,
    );

    $validation->validate;

    my $has_error = $self->has_error;

    if ($has_error) {
        for my $each_error (@{ $self->errors }) {
            $each_error->set_trace(Devel::StackTrace->new(skip_frames => 1));
        }

        die $validation->error_handler
            if $self->throwable;
    }

    return $has_error ? 0 : 1;
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

