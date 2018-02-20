package JIP::Guard::Factory::Validation;

use strict;
use warnings;

use English qw(-no_match_vars);

our $VERSION = '0.01';

sub create_for_request {
    my ($class, %param) = @ARG;

    my $type = q{};
    if (exists $param{'value'}) {
        $type              = 'Value';
        $param{'document'} = delete $param{'value'};
    }
    elsif (exists $param{'ref'}) {
        $type              = 'Ref';
        $param{'document'} = delete $param{'ref'};
    }

    return $class->create(type => $type, xargs => \%param);
}

sub create {
    my ($class, %param) = @ARG;

    my $type = $param{'type'};

    my $checks_location = sprintf 'JIP/Guard/Validation/%s.pm', $type;
    my $checks_class    = sprintf 'JIP::Guard::Validation::%s', $type;

    require $checks_location;

    return $checks_class->new(%{ $param{xargs} });
}

1;

