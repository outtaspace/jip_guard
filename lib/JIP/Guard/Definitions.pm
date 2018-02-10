package JIP::Guard::Definitions;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

use JIP::Guard::Definition;

our $VERSION = '0.01';

has stash => (get => q{-}, set => q{-});

sub TYPE {
    croak q{Method "TYPE" not implemented};
}

sub CONSTRAINTS {
    croak q{Method "CONSTRAINTS" not implemented};
}

sub new {
    my ($class, %param) = @ARG;

    my $stash = {};
    foreach my $each_constraint (@{ $class->CONSTRAINTS }) {
        my $constraint_value = $param{$each_constraint};

        if (!defined $constraint_value && $each_constraint eq $class->TYPE) {
            $constraint_value = 1;
        }

        $stash->{$each_constraint} = JIP::Guard::Definition->new(
            constraint       => $each_constraint,
            constraint_value => $constraint_value,
        );
    }

    return bless({}, $class)->_set_stash($stash);
}

sub build_check_sequence {
    my ($self) = @ARG;

    my $stash = $self->_stash;

    my @checks;
    for my $each_constraint (@{ $self->CONSTRAINTS }) {
        my $definition = $stash->{$each_constraint};

        next unless defined $definition->constraint_value;

        push @checks, $definition;
    }

    return @checks;
}

sub get_constraint_value {
    my ($self, $constraint) = @ARG;

    my $stash = $self->_stash;

    croak(sprintf q{Definition "%s" is not exists}, $constraint)
        unless exists $stash->{$constraint};

    return $stash->{$constraint};
}

1;

