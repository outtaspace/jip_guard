package JIP::Guard::Checks::Ref;

use parent 'JIP::Guard::Checks';

use strict;
use warnings;

use Scalar::Util qw(reftype);
use English qw(-no_match_vars);

our $VERSION = '0.01';

sub check_for_ref {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NO_NEED_TO_CONTINUE
        unless defined $document;

    my $expected = 1;
    my $got      = defined reftype($document) ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_reftype {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NO_NEED_TO_CONTINUE
        unless defined $document;

    my $expected = $definition->constraint_value;
    my $got      = defined reftype($document) ? reftype($document) : q{};

    if ($got ne $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

1;

