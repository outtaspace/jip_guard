package JIP::Guard::Checks;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use List::MoreUtils qw(any);
use Scalar::Util qw(reftype);
use English qw(-no_match_vars);

use constant NEED_TO_CONTINUE    => 1;
use constant NO_NEED_TO_CONTINUE => 0;

our $VERSION = '0.01';

has validation => (get => q{+}, set => q{-});

sub new {
    my ($class, %param) = @ARG;

    # Mandatory params
    croak q{Mandatory argument "validation" is missing}
        unless exists $param{'validation'};

    return bless({}, $class)->_set_validation($param{'validation'});
}

sub schema {
    my $self = shift;

    return $self->validation->schema;
}

sub document {
    my $self = shift;

    return $self->validation->document;
}

sub record_error {
    my ($self, %xargs) = @ARG;

    $self->validation->record_error(
        %xargs,
        schema   => $self->schema,
        document => $self->document,
    );

    return $self;
}

sub check_for_defined {
    my ($self, $definition) = @ARG;

    my $expected = $definition->constraint_value ? 1 : 0;
    my $got      = defined $self->document       ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

1;

