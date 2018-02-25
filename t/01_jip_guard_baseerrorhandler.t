#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use Scalar::Util qw(refaddr);
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

subtest 'new()' => sub {
    plan tests => 4;

    my $o = JIP::Guard::BaseErrorHandler->new;
    ok $o, 'got instance of JIP::Guard::BaseErrorHandler';

    isa_ok $o, 'JIP::Guard::BaseErrorHandler';

    can_ok $o, qw(new errors has_error add start end);

    is_deeply $o->errors, [];
};

subtest 'start()' => sub {
    plan tests => 5;

    my $o = JIP::Guard::BaseErrorHandler->new;

    cmp_ok $o->_active, q{==}, 0;

    my $oldErrorsAddr = refaddr $o->errors;

    $o = $o->start;

    isa_ok $o, 'JIP::Guard::BaseErrorHandler';

    cmp_ok $o->_active, q{==}, 1;

    my $newErrorsAddr = refaddr $o->errors;

    isnt $newErrorsAddr, $oldErrorsAddr;
    is_deeply $o->errors, [];
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
        plan tests => 3;

        my $o = JIP::Guard::BaseErrorHandler->new;

        $o->add(1)->add(1);

        is_deeply $o->errors, [];

        $o->start->add(2)->add(2)->end;

        $o->add(3)->add(3);

        is_deeply $o->errors, [2, 2];

        $o->start;

        is_deeply $o->errors, [];
    };
};

subtest 'has_error()' => sub {
    plan tests => 2;

    my $o = JIP::Guard::BaseErrorHandler->new;

    is $o->has_error, 0;

    $o->start->add(1);

    is $o->has_error, 1;
};

