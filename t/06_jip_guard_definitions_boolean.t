#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 5;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definitions::Boolean', '0.01';
    require_ok 'JIP::Guard::Definitions::Boolean';

    diag(
        sprintf 'Testing JIP::Guard::Definitions::Boolean %s, Perl %s, %s',
            $JIP::Guard::Definitions::Boolean::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::Definitions::Boolean->new;
    ok $o, 'got instance of JIP::Guard::Definitions::Boolean';

    isa_ok $o, 'JIP::Guard::Definitions';
    isa_ok $o, 'JIP::Guard::Definitions::Boolean';

    can_ok $o, qw(TYPE CONSTRAINTS new build_check_sequence);
};

subtest 'TYPE' => sub {
    plan tests => 1;

    my $type = JIP::Guard::Definitions::Boolean->TYPE;
    is $type, 'boolean';
};

subtest 'CONSTRAINTS' => sub {
    plan tests => 1;

    my $constraints = JIP::Guard::Definitions::Boolean->CONSTRAINTS;
    is_deeply $constraints, [qw(
        defined
        boolean
        true
        false
    )];
};

subtest 'build_check_sequence()' => sub {
    plan tests => 9;

    subtest 'without any params' => sub {
        plan tests => 4;

        my $o = JIP::Guard::Definitions::Boolean->new;

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 1;

        is $checks[0]->constraint,       'boolean';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_boolean';
    };

    subtest 'with defined=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Boolean->new(defined => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'boolean';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_boolean';
    };

    subtest 'with defined=0' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Boolean->new(defined => 0);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 0;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'boolean';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_boolean';
    };

    subtest 'with true=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Boolean->new(true => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'boolean';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_boolean';

        is $checks[1]->constraint,       'true';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_true';
    };

    subtest 'with true=0' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Boolean->new(true => 0);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'boolean';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_boolean';

        is $checks[1]->constraint,       'true';
        is $checks[1]->constraint_value, 0;
        is $checks[1]->method,           'check_for_true';
    };

    subtest 'with false=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Boolean->new(false => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'boolean';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_boolean';

        is $checks[1]->constraint,       'false';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_false';
    };

    subtest 'with false=0' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Boolean->new(false => 0);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'boolean';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_boolean';

        is $checks[1]->constraint,       'false';
        is $checks[1]->constraint_value, 0;
        is $checks[1]->method,           'check_for_false';
    };

    subtest 'with all definitions with true values' => sub {
        plan tests => 5;

        my $o = JIP::Guard::Definitions::Boolean->new(
            defined => 1,
            true    => 1,
            false   => 1,
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 4;

        is $checks[0]->constraint, 'defined';
        is $checks[1]->constraint, 'boolean';
        is $checks[2]->constraint, 'true';
        is $checks[3]->constraint, 'false';
    };

    subtest 'with all definitions with false values' => sub {
        plan tests => 5;

        my $o = JIP::Guard::Definitions::Boolean->new(
            defined => 0,
            true    => 0,
            false   => 0,
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 4;

        is $checks[0]->constraint, 'defined';
        is $checks[1]->constraint, 'boolean';
        is $checks[2]->constraint, 'true';
        is $checks[3]->constraint, 'false';
    };
};

