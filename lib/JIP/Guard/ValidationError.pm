package JIP::Guard::ValidationError;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

our $VERSION = '0.01';

has [qw(schema definition document subtype)] => (get => q{+}, set => q{-});

has 'trace' => (get => q{+}, set => q{+});

sub new {
    my ($class, %param) = @ARG;

    # Mandatory params
    croak q{Mandatory argument "schema" is missing}
        unless exists $param{'schema'};

    croak q{Mandatory argument "definition" is missing}
        unless exists $param{'definition'};

    croak q{Mandatory argument "document" is missing}
        unless exists $param{'document'};

    return bless({}, $class)
        ->set_trace($param{'trace'})
        ->_set_subtype($param{'subtype'})
        ->_set_schema($param{'schema'})
        ->_set_definition($param{'definition'})
        ->_set_document($param{'document'});
}

1;

