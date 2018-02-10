package JIP::Guard;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

use JIP::Guard::BaseErrorHandler;
use JIP::Guard::Validation::Value;
use JIP::Guard::Validation::Ref;

our $VERSION = '0.01';

has [qw(purge_unknown allow_unknown)] => (get => q{+}, set => q{+});

has [qw(registry errors error_handler)] => (get => q{+}, set => q{-});

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
        ->_set_errors([])
        ->_set_error_handler($error_handler)
        ->set_purge_unknown($purge_unknown)
        ->set_allow_unknown($allow_unknown);
}

sub validate {
    my ($self, %param) = @ARG;

    # TODO move to factory JIP::Guard::Factory::Validation
    croak q{Mandatory argument "schema" is missing}
        unless exists $param{'schema'};

    $self->_clear_errors;

    # TODO move to factory JIP::Guard::Factory::Validation
    my %validation_param = (
        registry      => $self->registry,
        error_handler => $self->error_handler,
        schema        => $param{'schema'},
    );

    # TODO move to factory JIP::Guard::Factory::Validation
    my $validation = do {
        my $class;

        if (exists $param{'value'}) {
            $class                        = 'JIP::Guard::Validation::Value';
            $validation_param{'document'} = $param{'value'};
        }
        elsif (exists $param{'ref'}) {
            $class                        = 'JIP::Guard::Validation::Ref';
            $validation_param{'document'} = $param{'ref'};
        }

        $class->new(%validation_param);
    };

    $validation->validate;

    $self->_copy_errors;
}

sub validated {
    croak q{Method "validated" not implemented};
}

sub _clear_errors {
    my $self = shift;

    my $errors = $self->errors;

    shift @{ $errors } while @{ $errors };

    return $self;
}

sub _copy_errors {
    my $self = shift;

    $self->_clear_errors;

    my $errors = $self->errors;

    foreach my $error (@{ $self->error_handler->errors }) {
        push @{ $errors }, $error;
    }

    return $self;
}

1;

