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

    my $expected = 'ARRAY';
    my $got      = reftype($document) || q{};

    if ($got ne $expected) {
        $self->record_error(definition => $definition);

        return $self->NO_NEED_TO_CONTINUE;
    }

    return $self->NEED_TO_CONTINUE;
}

1;

