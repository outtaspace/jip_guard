package JIP::Guard::Checks::String;

use parent 'JIP::Guard::Checks';

use strict;
use warnings;

use Scalar::Util qw(reftype);
use English qw(-no_match_vars);

sub check_for_string {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    my $expected = $definition->constraint_value;
    my $got      = reftype($document) // 'string' ? 1 : 0;

    if ($got ne $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_in {
    my ($self, $definition) = @ARG;

to_debug_count();

    my $document = $self->document;

    my $expected = 1;
    my $got      = 0;

    for my $each_item (@{ $definition->constraint_value }) {
        if (!defined $document && !defined $each_item) {
            $got = 1;
            last;
        }
        elsif (defined $document && defined $each_item) {
            if ($document eq $each_item) {
                $got = 1;
                last;
            }
        }
    }

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_min_length {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NEED_TO_CONTINUE
        unless defined $document;

    my $expected = 1;
    my $got      = length($document) >= $definition->constraint_value ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_max_length {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NEED_TO_CONTINUE
        unless defined $document;

    my $expected = 1;
    my $got      = length($document) <= $definition->constraint_value ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_empty {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NEED_TO_CONTINUE
        unless defined $document;

    my $expected = $definition->constraint_value ? 1 : 0;
    my $got      = length($document) == 0        ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_like {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NEED_TO_CONTINUE
        unless defined $document;

    my $expected = 1;
    my $got      = $document =~ $definition->constraint_value ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_verify {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    my $expected = 1;
    my $got      = $definition->constraint_value->($self) ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);
    }

    return $self->NEED_TO_CONTINUE;
}

1;

