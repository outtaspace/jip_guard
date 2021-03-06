#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);
use Mock::Quick qw(qtakeover qobj qmeth);

plan tests => 9;

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
        _create_checks_for
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

subtest 'validate()' => sub {
    plan tests => 2;

    my $sequence = [];

    my $control = qtakeover 'JIP::Guard::Validation' => (
        _set_up => qmeth {
            my $self = shift;
            push @{ $sequence }, '_set_up';
            return $self;
        },
        _check => qmeth {
            my $self = shift;
            push @{ $sequence }, '_check';
            return $self;
        },
        _tear_down => qmeth {
            my $self = shift;
            push @{ $sequence }, '_tear_down';
            return $self;
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => 'registry is present',
        error_handler => 'error_handler is present',
    );

    $o = $o->validate;
    isa_ok $o, 'JIP::Guard::Validation';

    is_deeply $sequence, [qw(_set_up _check _tear_down)];
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

subtest '_check()' => sub {
    plan tests => 6;

    my $definitions = qobj(
        build_check_sequence => qmeth {
            pass 'build_check_sequence method is invoked';

            return (
                qobj(
                    constraint       => qmeth { return 'foo'; },
                    constraint_value => qmeth { return undef; },
                    method           => qmeth { return 'check_for_foo'; },
                ),
                qobj(
                    constraint       => qmeth { return 'skip_next_ensuing'; },
                    constraint_value => qmeth { return undef; },
                    method           => qmeth { return 'check_for_skip_next_ensuing'; },
                ),
                qobj(
                    constraint       => qmeth { return 'bar'; },
                    constraint_value => qmeth { return undef; },
                    method           => qmeth { return 'check_for_bar'; },
                ),
            );
        },
    );

    my $registry = qobj(
        get => qmeth {
            my ($self, $schema) = @ARG;

            is $schema, 'schema is present';

            return $definitions;
        },
    );

    my $control = qtakeover 'JIP::Guard::Validation' => (
        _set_up => qmeth {
            fail '_set_up method is invoked';
        },
        _tear_down => qmeth {
            fail '_tear_down method is invoked';
        },
        _create_checks_for => qmeth {
            pass '_create_checks_for method is invoked';

            return qobj(
                check_for_foo => qmeth {
                    pass 'check_for_foo method is invoked';
                    return 1; # NEED_TO_CONTINUE
                },
                check_for_skip_next_ensuing => qmeth {
                    pass 'check_for_skip_next_ensuing method is invoked';
                    return 0; # NO_NEED_TO_CONTINUE
                },
                check_for_bar => qmeth {
                    fail 'check_for_bar method is invoked';
                },
            );
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => $registry,
        error_handler => qobj(),
    );

    $o = $o->_check;
    isa_ok $o, 'JIP::Guard::Validation';
};

subtest '_check() if schema is not exists' => sub {
    plan tests => 2;

    my $registry = qobj(
        get => qmeth {
            pass 'get() is invoked';
            return undef;
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'tratata schema',
        registry      => $registry,
        error_handler => qobj(),
    );

    throws_ok { $o->_check; } qr{
        No \s definitions \s found \s for \s "tratata \s schema"
    }x;
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

subtest '_create_checks_for()' => sub {
    plan tests => 3;

    my $control = qtakeover 'JIP::Guard::Factory::Checks' => (
        create_for_definitions_instance => qmeth {
            my ($self, %param) = @ARG;

            isa_ok $self, 'JIP::Guard::Factory::Checks';
            is $param{'definitions'}->constraint, 'wtf';

            return 42;
        },
    );

    my $o = JIP::Guard::Validation->new(
        document      => 'document is present',
        schema        => 'schema is present',
        registry      => 'registry is present',
        error_handler => 'error_handler is present',
    );

    my $definitions = qobj(
        constraint => qmeth { return 'wtf'; },
    );

    is $o->_create_checks_for($definitions), 42;
};

