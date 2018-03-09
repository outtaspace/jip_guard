#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);

use constant PERLISH_TRUE  => !!1;
use constant PERLISH_FALSE => !!0;

plan tests => 6;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard', '0.01';
    require_ok 'JIP::Guard';

    diag(
        sprintf 'Testing JIP::Guard %s, Perl %s, %s',
            $JIP::Guard::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 12;

    throws_ok { JIP::Guard->new; } qr{
        Mandatory \s argument \s "registry" \s is \s missing
    }x;

    my $o = JIP::Guard->new(registry => 'tratata registry');
    ok $o, 'got instance of JIP::Guard';

    isa_ok $o, 'JIP::Guard';

    can_ok $o, qw(
        purge_unknown
        set_purge_unknown
        allow_unknown
        set_allow_unknown
        set_throwable
        throwable
    );

    can_ok $o, qw(registry error_handler);

    can_ok $o, qw(validate errors has_error);

    cmp_ok $o->registry, 'eq', 'tratata registry';
    is_deeply $o->errors, [];
    cmp_ok $o->purge_unknown, '==', 0;
    cmp_ok $o->allow_unknown, '==', 1;
    cmp_ok $o->throwable,     '==', 0;
    is ref($o->error_handler), 'JIP::Guard::BaseErrorHandler';
};

subtest 'new(purge_unknown)' => sub {
    plan tests => 2;

    my $o = JIP::Guard->new(
        registry      => 'tratata registry',
        purge_unknown => PERLISH_TRUE,
    );
    cmp_ok $o->purge_unknown, '==', 1;


    $o = JIP::Guard->new(
        registry      => 'tratata registry',
        purge_unknown => PERLISH_FALSE,
    );
    cmp_ok $o->purge_unknown, '==', 0;
};

subtest 'new(allow_unknown)' => sub {
    plan tests => 2;

    my $o = JIP::Guard->new(
        registry      => 'tratata registry',
        allow_unknown => PERLISH_TRUE,
    );
    cmp_ok $o->allow_unknown, '==', 1;

    $o = JIP::Guard->new(
        registry      => 'tratata registry',
        allow_unknown => PERLISH_FALSE,
    );
    cmp_ok $o->allow_unknown, '==', 0;
};

subtest 'new(throwable)' => sub {
    plan tests => 2;

    my $o = JIP::Guard->new(
        registry  => 'tratata registry',
        throwable => PERLISH_TRUE,
    );
    cmp_ok $o->throwable, '==', 1;

    $o = JIP::Guard->new(
        registry  => 'tratata registry',
        throwable => PERLISH_FALSE,
    );
    cmp_ok $o->throwable, '==', 0;
};

subtest 'new(error_handler)' => sub {
    plan tests => 1;

    my $o = JIP::Guard->new(
        registry      => 'tratata registry',
        error_handler => 'tratata error_handler',
    );
    is $o->error_handler, 'tratata error_handler';
};

