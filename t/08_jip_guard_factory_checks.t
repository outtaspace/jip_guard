#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);
use Mock::Quick qw(qclass);

plan tests => 3;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Factory::Checks', '0.01';
    require_ok 'JIP::Guard::Factory::Checks';

    diag(
        sprintf 'Testing JIP::Guard::Factory::Checks %s, Perl %s, %s',
            $JIP::Guard::Factory::Checks::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'create()' => sub {
    plan tests => 2;

    my $control = qclass(
        -implement => 'JIP::Guard::Checks::TestMe',
        new => sub {
            my ($class, %param) = @ARG;

            is_deeply \%param, {testme => 'testme value'};

            return $class;
        },
    );

    my $o = JIP::Guard::Factory::Checks->create(
        type => 'TestMe',
        xargs => {testme => 'testme value'},
    );
    isa_ok $o, 'JIP::Guard::Checks::TestMe';
};

subtest 'create_for_definitions_instance()' => sub {
    plan tests => 4;

    my $checks_control = qclass(
        -implement => 'JIP::Guard::Checks::TestMe',
        new => sub {
            my ($class, %param) = @ARG;

            isa_ok $param{definitions}, 'JIP::Guard::Definitions::TestMe';
            is_deeply $param{xargs}, {testme => 'testme value'};

            return $class;
        },
    );

    my $definitions_control = qclass(
        -implement => 'JIP::Guard::Definitions::TestMe',
        -with_new  => 1,
    );

    my $definitions = $definitions_control->package->new;
    isa_ok $definitions, 'JIP::Guard::Definitions::TestMe';

    my $o = JIP::Guard::Factory::Checks->create_for_definitions_instance(
        definitions => $definitions,
        xargs       => {testme => 'testme value'},
    );
    isa_ok $o, 'JIP::Guard::Checks::TestMe';
};

