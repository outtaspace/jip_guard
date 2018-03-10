#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 5;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definitions::HashElement', '0.01';
    require_ok 'JIP::Guard::Definitions::HashElement';

    diag(
        sprintf 'Testing JIP::Guard::Definitions::HashElement %s, Perl %s, %s',
            $JIP::Guard::Definitions::HashElement::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::Definitions::HashElement->new;
    ok $o, 'got instance of JIP::Guard::Definitions::HashElement';

    isa_ok $o, 'JIP::Guard::Definitions';
    isa_ok $o, 'JIP::Guard::Definitions::HashElement';

    can_ok $o, qw(TYPE CONSTRAINTS new build_check_sequence);
};

subtest 'TYPE' => sub {
    plan tests => 1;

    my $type = JIP::Guard::Definitions::HashElement->TYPE;
    is $type, 'hash_element';
};

subtest 'CONSTRAINTS' => sub {
    plan tests => 1;

    my $constraints = JIP::Guard::Definitions::HashElement->CONSTRAINTS;
    is_deeply $constraints, [qw(
        hash_element
        required
        schema
    )];
};

subtest 'build_check_sequence()' => sub {
    plan tests => 5;

    subtest 'without any params' => sub {
        plan tests => 4;

        my $o = JIP::Guard::Definitions::HashElement->new;

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 1;

        is $checks[0]->constraint,       'hash_element';
        is $checks[0]->constraint_value, 1;
        is $checks[0]->method,           'check_for_hash_element';
    };

    subtest 'with hash_element=tratata' => sub {
        plan tests => 4;

        my $o = JIP::Guard::Definitions::HashElement->new(
            hash_element => 'tratata',
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 1;

        is $checks[0]->constraint,       'hash_element';
        is $checks[0]->constraint_value, 'tratata';
        is $checks[0]->method,           'check_for_hash_element';

    };

    subtest 'with required=1' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::HashElement->new(
            hash_element => 'tratata',
            required     => 1,
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'hash_element';
        is $checks[0]->constraint_value, 'tratata';
        is $checks[0]->method,           'check_for_hash_element';

        is $checks[1]->constraint,       'required';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_required';
    };

    subtest 'with schema' => sub {
        plan tests => 7;

        my $o = JIP::Guard::Definitions::HashElement->new(
            hash_element => 'tratata',
            schema       => 'tratata schema',
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 2;

        is $checks[0]->constraint,       'hash_element';
        is $checks[0]->constraint_value, 'tratata';
        is $checks[0]->method,           'check_for_hash_element';

        is $checks[1]->constraint,       'schema';
        is $checks[1]->constraint_value, 'tratata schema';
        is $checks[1]->method,           'check_for_schema';
    };

    subtest 'with all definitions' => sub {
        plan tests => 10;

        my $o = JIP::Guard::Definitions::HashElement->new(
            hash_element => 'tratata',
            required     => 1,
            schema       => 'tratata schema',
        );

        my @checks = $o->build_check_sequence;
        is scalar(@checks), 3;

        is $checks[0]->constraint,       'hash_element';
        is $checks[0]->constraint_value, 'tratata';
        is $checks[0]->method,           'check_for_hash_element';

        is $checks[1]->constraint,       'required';
        is $checks[1]->constraint_value, 1;
        is $checks[1]->method,           'check_for_required';

        is $checks[2]->constraint,       'schema';
        is $checks[2]->constraint_value, 'tratata schema';
        is $checks[2]->method,           'check_for_schema';
    };
};

