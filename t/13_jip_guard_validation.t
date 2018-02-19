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

    use_ok 'JIP::Guard::Validation', '0.01';
    require_ok 'JIP::Guard::Validation';

    diag(
        sprintf 'Testing JIP::Guard::Validation %s, Perl %s, %s',
            $JIP::Guard::Validation::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'abstract methods' => sub {
    plan tests => 2;

    throws_ok { JIP::Guard::Validation->_check; } qr{
        Method \s "_check" \s not \s implemented
    }x;

    throws_ok { JIP::Guard::Validation->validate; } qr{
        Method \s "validate" \s not \s implemented
    }x;
};

subtest 'new()' => sub {
    plan tests => 11;

    throws_ok {
        JIP::Guard::Validation->new(
            schema        => 1,
            registry      => 1,
            error_handler => 1,
        );
    }
    qr{Mandatory \s argument \s "document" \s is \s missing}x;

    throws_ok {
        JIP::Guard::Validation->new(
            document      => 1,
            registry      => 1,
            error_handler => 1,
        );
    }
    qr{Mandatory \s argument \s "schema" \s is \s missing}x;

    throws_ok {
        JIP::Guard::Validation->new(
            document      => 1,
            schema        => 1,
            error_handler => 1,
        );
    }
    qr{Mandatory \s argument \s "registry" \s is \s missing}x;

    throws_ok {
        JIP::Guard::Validation->new(
            document      => 1,
            schema        => 1,
            registry      => 1,
        );
    }
    qr{Mandatory \s argument \s "error_handler" \s is \s missing}x;

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => 'registry is present',
        error_handler => 'error_handler is present',
    );
    ok $o, 'got instance of JIP::Guard::Validation';

    isa_ok $o, 'JIP::Guard::Validation';

    can_ok $o, qw(
        new
        document
        schema
        registry
        error_handler
        _set_up
        _check
        _tear_down
    );

    is $o->document,      'document is present';
    is $o->schema,        'schema is present';
    is $o->registry,      'registry is present';
    is $o->error_handler, 'error_handler is present';
};

subtest 'record_error()' => sub {
    plan tests => 4;

    my $control = qtakeover 'JIP::Guard::ValidationError' => (
        new => qmeth {
            my ($class, %param) = @ARG;

            is $class, 'JIP::Guard::ValidationError';
            is_deeply \%param, {key => 'value'};

            return 'instance of '. $class;
        },
    );

    my $error_handler = qobj(
        add => qmeth {
            my ($self, $error) = @ARG;

            is $error, 'instance of JIP::Guard::ValidationError';
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => 'registry is present',
        error_handler => $error_handler,
    );

    $o = $o->record_error(key => 'value');
    isa_ok $o, 'JIP::Guard::Validation';
};

subtest '_set_up()' => sub {
    plan tests => 2;

    my $error_handler = qobj(
        start => qmeth {
            pass 'start is invoked';
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => 'registry is present',
        error_handler => $error_handler,
    );

    $o = $o->_set_up;
    isa_ok $o, 'JIP::Guard::Validation';
};

subtest '_tear_down()' => sub {
    plan tests => 2;

    my $error_handler = qobj(
        end => qmeth {
            pass 'end is invoked';
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => 'registry is present',
        error_handler => $error_handler,
    );

    $o = $o->_tear_down;
    isa_ok $o, 'JIP::Guard::Validation';
};

