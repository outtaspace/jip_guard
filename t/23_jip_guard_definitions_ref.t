#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 5;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definitions::Ref', '0.01';
    require_ok 'JIP::Guard::Definitions::Ref';

    diag(
        sprintf 'Testing JIP::Guard::Definitions::Ref %s, Perl %s, %s',
            $JIP::Guard::Definitions::Ref::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::Definitions::Ref->new;
    ok $o, 'got instance of JIP::Guard::Definitions::Ref';

    isa_ok $o, 'JIP::Guard::Definitions';
    isa_ok $o, 'JIP::Guard::Definitions::Ref';

    can_ok $o, qw(TYPE CONSTRAINTS new build_check_sequence);
};

subtest 'TYPE' => sub {
    plan tests => 1;

    my $type = JIP::Guard::Definitions::Ref->TYPE;
    is $type, 'ref';
};

subtest 'CONSTRAINTS' => sub {
    plan tests => 1;

    my $constraints = JIP::Guard::Definitions::Ref->CONSTRAINTS;
    is_deeply $constraints, [qw(defined ref reftype)];
};

subtest 'build_check_sequence()' => sub {
    plan tests => 4;

    subtest 'without any params' => sub {
        plan tests => 4;

        my $o = JIP::Guard::Definitions::Ref->new;

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 1;

        is $checks[0]->constraint,       'ref';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_ref';
    };

    subtest 'with defined=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Ref->new(defined => 1);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'ref';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_ref';
    };

    subtest 'with defined=0' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Ref->new(defined => 0);

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'defined';
        is $checks[0]->constraint_value, 0;
        is $checks[0]->method,           'check_for_defined';

        is $checks[1]->constraint,       'ref';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_ref';
    };

    subtest 'with reftype=ARRAY' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::Ref->new(reftype => 'ARRAY');

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'ref';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_ref';

        is $checks[1]->constraint,       'reftype';
        is $checks[1]->constraint_value, 'ARRAY';
        is $checks[1]->method,           'check_for_reftype';
    };
};

