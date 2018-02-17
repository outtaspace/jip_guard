#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 5;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definitions::String', '0.01';
    require_ok 'JIP::Guard::Definitions::String';

    diag(
        sprintf 'Testing JIP::Guard::Definitions::String %s, Perl %s, %s',
            $JIP::Guard::Definitions::String::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::Definitions::String->new;
    ok $o, 'got instance of JIP::Guard::Definitions::String';

    isa_ok $o, 'JIP::Guard::Definitions';
    isa_ok $o, 'JIP::Guard::Definitions::String';

    can_ok $o, qw(TYPE CONSTRAINTS new build_check_sequence);
};

subtest 'TYPE' => sub {
    plan tests => 1;

    my $type = JIP::Guard::Definitions::String->TYPE;
    is $type, 'string';
};

subtest 'CONSTRAINTS' => sub {
    plan tests => 1;

    my $constraints = JIP::Guard::Definitions::String->CONSTRAINTS;
    is_deeply $constraints, [qw(
        defined
        string
        in
        min_length
        max_length
        empty
        like
        verify
    )];
};
subtest 'build_check_sequence()' => sub {
    plan tests => 10;

    subtest 'without any params' => sub {
        plan tests => 4;

        my $o = JIP::Guard::Definitions::String->new;

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 1;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';
    };

    subtest 'with defined=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(defined => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'string';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_string';
    };

    subtest 'with defined=0' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(defined => 0);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 0;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'string';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_string';
    };

    subtest 'with in=[]' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(in => []);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';

        is $checks[1]->constraint,            'in';
        is ref($checks[1]->constraint_value), 'ARRAY';
        is $checks[1]->method,                'check_for_in';
    };

    subtest 'with min_length' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(min_length => 42);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';

        is $checks[1]->constraint,       'min_length';
        is $checks[1]->constraint_value, 42;
        is $checks[1]->method,           'check_for_min_length';
    };

    subtest 'with max_length' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(max_length => 42);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';

        is $checks[1]->constraint,       'max_length';
        is $checks[1]->constraint_value, 42;
        is $checks[1]->method,           'check_for_max_length';
    };

    subtest 'with empty' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(empty => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';

        is $checks[1]->constraint,       'empty';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_empty';
    };

    subtest 'with like' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(like => qr{}x);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';

        is $checks[1]->constraint,       'like';
        is $checks[1]->constraint_value, qr{}x;
        is $checks[1]->method,           'check_for_like';
    };

    subtest 'with verify' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::String->new(verify => sub {});

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'string';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_string';

        is $checks[1]->constraint,            'verify';
        is ref($checks[1]->constraint_value), 'CODE';
        is $checks[1]->method,                'check_for_verify';
    };

    subtest 'with all definitions with true values' => sub {
        plan tests => 9;

        my $o = JIP::Guard::Definitions::String->new(
            defined    => 1,
            in         => [],
            min_length => 1,
            max_length => 1,
            empty      => 1,
            like       => qr{}x,
            verify     => sub {},
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 8;

        is $checks[0]->constraint, 'defined';
        is $checks[1]->constraint, 'string';
        is $checks[2]->constraint, 'in';
        is $checks[3]->constraint, 'min_length';
        is $checks[4]->constraint, 'max_length';
        is $checks[5]->constraint, 'empty';
        is $checks[6]->constraint, 'like';
        is $checks[7]->constraint, 'verify';
    };
};

