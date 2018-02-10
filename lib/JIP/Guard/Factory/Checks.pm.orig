package JIP::Guard::Factory::Checks;

use strict;
use warnings;

use English qw(-no_match_vars);

our $VERSION = '0.01';

sub create_for_definitions_instance {
    my ($class, %param) = @ARG;

    my ($type) = ref($param{'definitions'}) =~ m{^JIP::Guard::Definitions::(.+)$}x;

    return $class->create(type => $type, xargs => \%param);
}

sub create {
    my ($class, %param) = @ARG;

    my $type = $param{'type'};

    my $checks_location = sprintf 'JIP/Guard/Checks/%s.pm', $type;
    my $checks_class    = sprintf 'JIP::Guard::Checks::%s', $type;

    require $checks_location;

    return $checks_class->new(%{ $param{xargs} });
}

1;

