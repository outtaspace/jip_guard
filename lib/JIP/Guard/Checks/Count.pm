package JIP::Guard::Checks::Count;

use parent 'JIP::Guard::Checks';

use strict;
use warnings;

use Data::Types qw(is_count);
use English qw(-no_match_vars);

our $VERSION = '0.01';

sub check_for_count {
    my ($self, $definition) = @ARG;

    my $document = $self->document;

    return $self->NO_NEED_TO_CONTINUE
        unless defined $document;

    my $expected = 1;
    my $got      = is_count($document) ? 1 : 0;

    if ($got != $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

1;

