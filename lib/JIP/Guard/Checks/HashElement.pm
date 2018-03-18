package JIP::Guard::Checks::HashElement;

use parent 'JIP::Guard::Checks';

use strict;
use warnings;

use Scalar::Util qw(reftype);
use English qw(-no_match_vars);

use JIP::Guard::Validation;
use JIP::Guard::BaseErrorHandler;

our $VERSION = '0.01';

sub check_for_hash_element {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    my $expected = 'HASH';
    my $got      = reftype($document) || q{};

    if ($got ne $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_required {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    my $expected = 1;
    my $got      = exists $document->{$self->schema} ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

sub check_for_schema {
    my ($self, $definition) = @ARG;

    return $self->NEED_TO_CONTINUE
        unless exists $self->document->{$self->schema};

    my $error_handler = JIP::Guard::BaseErrorHandler->new;

    my $validation = JIP::Guard::Validation->new(
        document      => $self->document->{$self->schema},
        schema        => $definition->constraint_value,
        registry      => $self->validation->registry,
        error_handler => $error_handler,
    );

    $validation->validate;

    if ($error_handler->has_error) {
        $self->record_error(
            definition => $definition,
            subtype    => $error_handler->errors,
        );

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

1;

