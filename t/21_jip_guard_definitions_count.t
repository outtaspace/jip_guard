#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 5;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definitions::Count', '0.01';
    require_ok 'JIP::Guard::Definitions::Count';

    diag(
        sprintf 'Testing JIP::Guard::Definitions::Count %s, Perl %s, %s',
            $JIP::Guard::Definitions::Count::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::Definitions::Count->new;
    ok $o, 'got instance of JIP::Guard::Definitions::Count';

    isa_ok $o, 'JIP::Guard::Definitions';
    isa_ok $o, 'JIP::Guard::Definitions::Count';

    can_ok $o, qw(TYPE CONSTRAINTS new build_check_sequence);
};

subtest 'TYPE' => sub {
    plan tests => 1;

    my $type = JIP::Guard::Definitions::Count->TYPE;
    is $type, 'count';
};

subtest 'CONSTRAINTS' => sub {
    plan tests => 1;

    my $constraints = JIP::Guard::Definitions::Count->CONSTRAINTS;
    is_deeply $constraints, [qw(defined count)];
};

subtest 'build_check_sequence()' => sub {
    plan tests => 3;

    subtest 'without any params' => sub {
        plan tests => 4;

        my $o = JIP::Guard::Definitions::Count->new;

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 1;

        is $checks[0]->constraint,       'count';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_count';
    };

    subtest 'with defined=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Count->new(defined => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'count';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_count';
    };

    subtest 'with defined=0' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Count->new(defined => 0);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 0;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'count';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_count';
    };
};

