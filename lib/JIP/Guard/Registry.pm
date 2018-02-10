package JIP::Guard::Registry;

use strict;
use warnings;

use JIP::ClassField;
use English qw(-no_match_vars);

our $VERSION = '0.01';

has definitions => (get => q{-}, set => q{-});

sub new {
    my ($class) = @ARG;

    return bless({}, $class)
        ->_set_definitions({});
}

sub add {
    my ($self, $name, $definition) = @ARG;

    $self->_definitions->{$name} = $definition;

    return $self;
}

sub extend {
    my ($self, %definition) = @ARG;

    while (my ($name, $definition) = each %definition) {
        $self->add($name, $definition);
    }

    return $self;
}

sub remove {
    my ($self, @names) = @ARG;

    map { delete $self->_definitions->{$_} } @names;

    return $self;
}

sub clear {
    my ($self) = @ARG;

    map { delete $self->_definitions->{$_} } keys %{ $self->_definitions };

    return $self;
}

sub get {
    my ($self, $name) = @ARG;

    return unless exists $self->_definitions->{$name};

    return $self->_definitions->{$name};
}

sub all {
    my ($self) = @ARG;

    return %{ $self->_definitions };
}

1;

