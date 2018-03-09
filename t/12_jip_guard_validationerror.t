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

    use_ok 'JIP::Guard::ValidationError', '0.01';
    require_ok 'JIP::Guard::ValidationError';

    diag(
        sprintf 'Testing JIP::Guard::ValidationError %s, Perl %s, %s',
            $JIP::Guard::ValidationError::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 12;

    throws_ok {
        JIP::Guard::ValidationError->new(
            definition => 'is present',
            document   => 'is present',
        );
    }
    qr{Mandatory \s argument \s "schema" \s is \s missing}x;

    throws_ok {
        JIP::Guard::ValidationError->new(
            schema   => 'is present',
            document => 'is present',
        );
    }
    qr{Mandatory \s argument \s "definition" \s is \s missing}x;

    throws_ok {
        JIP::Guard::ValidationError->new(
            schema     => 'is present',
            definition => 'is present',
        );
    }
    qr{Mandatory \s argument \s "document" \s is \s missing}x;

    my $o = JIP::Guard::ValidationError->new(
        schema     => 'schema',
        definition => 'definition',
        document   => 'document',
    );
    ok $o, 'got instance of JIP::Guard::ValidationError';

    isa_ok $o, 'JIP::Guard::ValidationError';

    can_ok $o, qw(
        new
        schema
        definition
        document
        trace
        set_trace
    );

    is $o->schema,     'schema';
    is $o->definition, 'definition';
    is $o->document,   'document';
    is $o->trace,      undef;

    is $o->set_trace(42)->trace, 42;

    $o = JIP::Guard::ValidationError->new(
        schema     => 'schema',
        definition => 'definition',
        document   => 'document',
        trace      => 42,
    );
    is $o->trace, 42;
};

