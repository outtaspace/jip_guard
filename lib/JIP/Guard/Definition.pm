package JIP::Guard::Definition;

use strict;
use warnings;

use JIP::ClassField;
use Carp qw(croak);
use English qw(-no_match_vars);

our $VERSION = '0.01';

has [qw(constraint constraint_value method)] => (get => q{+}, set => q{-});

sub new {
    my ($class, %param) = @ARG;

    # Mandatory params
    croak q{Mandatory argument "constraint" is missing}
        unless exists $param{'constraint'};

    croak q{Mandatory argument "constraint_value" is missing}
        unless exists $param{'constraint_value'};

    return bless({}, $class)
        ->_set_constraint($param{'constraint'})
        ->_set_constraint_value($param{'constraint_value'})
        ->_set_method(sprintf q{check_for_%s}, $param{'constraint'});
}

1;

