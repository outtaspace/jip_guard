#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);

plan tests => 2;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definition', '0.01';
    require_ok 'JIP::Guard::Definition';

    diag(
        sprintf 'Testing JIP::Guard::Definition %s, Perl %s, %s',
            $JIP::Guard::Definition::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 8;

    throws_ok {
        JIP::Guard::Definition->new(constraint_value => 'is present');
    }
    qr{Mandatory \s argument \s "constraint" \s is \s missing}x;

    throws_ok {
        JIP::Guard::Definition->new(constraint => 'is present');
    }
    qr{Mandatory \s argument \s "constraint_value" \s is \s missing}x;

    my $o = JIP::Guard::Definition->new(
        constraint       => 'string',
        constraint_value => '42',
    );
    ok $o, 'got instance of JIP::Guard::Definition';

    isa_ok $o, 'JIP::Guard::Definition';

    can_ok $o, qw(
        new
        constraint
        constraint_value
        method
    );

    is $o->constraint,       'string';
    is $o->constraint_value, '42';
    is $o->method,           'check_for_string';
};

