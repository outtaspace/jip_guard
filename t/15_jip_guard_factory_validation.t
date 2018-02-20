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

    use_ok 'JIP::Guard::Factory::Validation', '0.01';
    require_ok 'JIP::Guard::Factory::Validation';

    diag(
        sprintf 'Testing JIP::Guard::Factory::Validation %s, Perl %s, %s',
            $JIP::Guard::Factory::Validation::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'create()' => sub {
    plan tests => 2;

    my $control = qclass(
        -implement => 'JIP::Guard::Validation::TestMe',
        new => sub {
            my ($class, %param) = @ARG;

            is_deeply \%param, {testme => 'testme value'};

            return $class;
        },
    );

    my $o = JIP::Guard::Factory::Validation->create(
        type => 'TestMe',
        xargs => {testme => 'testme value'},
    );
    isa_ok $o, 'JIP::Guard::Validation::TestMe';
};

subtest 'create_for_request()' => sub {
    plan tests => 2;

    my $control = qclass(
        -implement => 'JIP::Guard::Validation::Value',
        new => sub {
            my ($class, %param) = @ARG;

            is_deeply \%param, {
                document => 42,
                xarg1 => 1,
                xarg2 => 2,
            };

            return $class;
        },
    );

    my $o = JIP::Guard::Factory::Validation->create_for_request(
        value => 42,
        xarg1 => 1,
        xarg2 => 2,
    );
    is $o, 'JIP::Guard::Validation::Value';
};

