#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);
use Mock::Quick qw(qtakeover qobj qmeth);

plan tests => 6;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Definitions', '0.01';
    require_ok 'JIP::Guard::Definitions';

    diag(
        sprintf 'Testing JIP::Guard::Definitions %s, Perl %s, %s',
            $JIP::Guard::Definitions::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'abstract methods' => sub {
    plan tests => 2;

    throws_ok { JIP::Guard::Definitions->TYPE; } qr{
        Method \s "TYPE" \s not \s implemented
    }x;

    throws_ok { JIP::Guard::Definitions->CONSTRAINTS; } qr{
        Method \s "CONSTRAINTS" \s not \s implemented
    }x;
};

subtest 'new()' => sub {
    plan tests => 4;

    my $control = qtakeover 'JIP::Guard::Definitions' => (
        CONSTRAINTS => qmeth {
            pass 'CONSTRAINTS method is invoked';
            return [];
        },
    );

    my $o = JIP::Guard::Definitions->new();
    ok $o, 'got instance of JIP::Guard::Definitions';

    isa_ok $o, 'JIP::Guard::Definitions';

    can_ok $o, qw(TYPE CONSTRAINTS new build_check_sequence);
};

subtest 'build_check_sequence() without any CONSTRAINTS' => sub {
    plan tests => 1;

    my $control = qtakeover 'JIP::Guard::Definitions' => (
        TYPE => qmeth {
            return 'wtf';
        },
        CONSTRAINTS => qmeth {
            return [];
        },
    );

    my $o = JIP::Guard::Definitions->new;

    my @checks = $o->build_check_sequence;

    is scalar(@checks), 0;
};

subtest 'build_check_sequence() when TYPE is one of the CONSTRAINTS' => sub {
    plan tests => 5;

    my $control = qtakeover 'JIP::Guard::Definitions' => (
        TYPE => qmeth {
            return 'wtf';
        },
        CONSTRAINTS => qmeth {
            return [qw(wtf)];
        },
    );

    my $o = JIP::Guard::Definitions->new;

    my @checks = $o->build_check_sequence;

    is scalar(@checks), 1;

    isa_ok $checks[0], 'JIP::Guard::Definition';

    is $checks[0]->constraint,       'wtf';
    is $checks[0]->constraint_value, 1;
    is $checks[0]->method,           'check_for_wtf';
};

subtest 'build_check_sequence()' => sub {
    plan tests => 9;

    my $control = qtakeover 'JIP::Guard::Definitions' => (
        TYPE => qmeth {
            return 'wtf';
        },
        CONSTRAINTS => qmeth {
            return [qw(is_present is_undefined is_not_present wtf)];
        },
    );

    my $o = JIP::Guard::Definitions->new(
        is_present   => 'is_present value',
        is_undefined => undef,
    );

    my @checks = $o->build_check_sequence;

    is scalar(@checks), 2;

    isa_ok $checks[0], 'JIP::Guard::Definition';

    is $checks[0]->constraint,       'is_present';
    is $checks[0]->constraint_value, 'is_present value';
    is $checks[0]->method,           'check_for_is_present';

    isa_ok $checks[0], 'JIP::Guard::Definition';

    is $checks[1]->constraint,       'wtf';
    is $checks[1]->constraint_value, 1;
    is $checks[1]->method,           'check_for_wtf';
};

