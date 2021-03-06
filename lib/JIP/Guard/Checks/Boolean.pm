package JIP::Guard::Checks::Boolean;

use parent 'JIP::Guard::Checks';

use strict;
use warnings;

use English qw(-no_match_vars);

our $VERSION = '0.01';

sub check_for_boolean {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NO_NEED_TO_CONTINUE
        unless defined $document;

    my $expected = 1;
    my $got      = $document =~ m{^(?:1|0)$}x;

    if ($got != $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_true {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NEED_TO_CONTINUE
        unless defined $document;

    my $expected = $definition->constraint_value ? 1 : 0;
    my $got      = $document =~ m{^1$}x          ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_false {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NEED_TO_CONTINUE
        unless defined $document;

    my $expected = $definition->constraint_value ? 1 : 0;
    my $got      = $document =~ m{^0$}x          ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

1;

