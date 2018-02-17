#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);

plan tests => 6;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::BaseErrorHandler', '0.01';
    require_ok 'JIP::Guard::BaseErrorHandler';

    diag(
        sprintf 'Testing JIP::Guard::BaseErrorHandler %s, Perl %s, %s',
            $JIP::Guard::BaseErrorHandler::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'abstract methods' => sub {
    plan tests => 1;

    throws_ok { JIP::Guard::BaseErrorHandler->extend; } qr{
        Method \s "extend" \s not \s implemented
    }x;
};

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::BaseErrorHandler->new;
    ok $o, 'got instance of JIP::Guard::BaseErrorHandler';

    isa_ok $o, 'JIP::Guard::BaseErrorHandler';

    can_ok $o, qw(new errors add extend start end);

    is_deeply $o->errors, [];
};

subtest 'start()' => sub {
    plan tests => 3;

    my $o = JIP::Guard::BaseErrorHandler->new;

    cmp_ok $o->_active, q{==}, 0;

    $o = $o->start;
    isa_ok $o, 'JIP::Guard::BaseErrorHandler';

    cmp_ok $o->_active, q{==}, 1;
};

subtest 'end()' => sub {
    plan tests => 2;

    my $o = JIP::Guard::BaseErrorHandler->new;

    $o = $o->start->end;
    isa_ok $o, 'JIP::Guard::BaseErrorHandler';

    cmp_ok $o->_active, q{==}, 0;
};

subtest 'add()' => sub {
    plan tests => 2;

    subtest 'inactive' => sub {
        plan tests => 2;

        my $o = JIP::Guard::BaseErrorHandler->new;

        $o = $o->add('first error');
        isa_ok $o, 'JIP::Guard::BaseErrorHandler';

        is_deeply $o->errors, [];
    };

    subtest 'active' => sub {
        plan tests => 1;

        my $o = JIP::Guard::BaseErrorHandler->new;

        $o->start;
        $o->add('first error');

        $o->end;
        $o->add('second error');

        $o->start;
        $o->add('third error');

        $o->end;
        $o->add('fourth error');

        is_deeply $o->errors, ['first error', 'third error'];
    };
};

