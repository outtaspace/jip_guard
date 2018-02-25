package JIP::Guard::BaseErrorHandler;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

our $VERSION = '0.01';

has errors => (get => q{+}, set => q{-});
has active => (get => q{-}, set => q{-});

sub new {
    my ($class, %param) = @ARG;

    return bless({}, $class)
        ->_set_active(0)
        ->_set_errors([]);
}

sub add {
    my ($self, $error) = @ARG;

    return $self unless $self->_active;

    push @{ $self->errors }, $error;

    return $self;
}

sub has_error {
    my $self = shift;

    return @{ $self->errors } ? 1 : 0;
}

sub start {
    my $self = shift;

    return $self->_set_errors([])->_set_active(1);
}

sub end {
    my $self = shift;

    return $self->_set_active(0);
}

1;

