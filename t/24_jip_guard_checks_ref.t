#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);
use Mock::Quick qw(qobj qmeth);

plan tests => 4;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Checks::Ref', '0.01';
    require_ok 'JIP::Guard::Checks::Ref';

    diag(
        sprintf 'Testing JIP::Guard::Checks::Ref %s, Perl %s, %s',
            $JIP::Guard::Checks::Ref::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 8;

    throws_ok {
        JIP::Guard::Checks::Ref->new;
    }
    qr{Mandatory \s argument \s "validation" \s is \s missing}x;

    my $o = JIP::Guard::Checks::Ref->new(validation => 'validation');
    ok $o, 'got instance of JIP::Guard::Checks::Ref';

    isa_ok $o, 'JIP::Guard::Checks';
    isa_ok $o, 'JIP::Guard::Checks::Ref';

    can_ok $o, qw(
        new
        validation
        schema
        document
        record_error
        check_for_defined
        check_for_ref
        check_for_reftype
        NEED_TO_CONTINUE
        NO_NEED_TO_CONTINUE
    );

    is $o->validation, 'validation';

    is $o->NEED_TO_CONTINUE,    1;
    is $o->NO_NEED_TO_CONTINUE, 0;
};

subtest 'check_for_ref()' => sub {
    plan tests => 3;

    subtest 'when document is not defined' => sub {
        plan tests => 2;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return undef;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                fail 'constraint_value is invoked';
                return 1;
            },
        );

        my $o = JIP::Guard::Checks::Ref->new(validation => $validation);
        my $result = $o->check_for_ref($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;
    };

    subtest 'when document is ref' => sub {
        plan tests => 2;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return [42];
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                fail 'constraint_value is invoked';
                return 1;
            },
        );

        my $o = JIP::Guard::Checks::Ref->new(validation => $validation);
        my $result = $o->check_for_ref($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is not ref' => sub {
        plan tests => 5;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'not ref';
            },
            record_error => qmeth {
                my ($self, %param) = @ARG;
                push @{ $errors }, \%param;
                return $self;
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                fail 'constraint_value is invoked';
                return 'HASH';
            },
        );

        my $o = JIP::Guard::Checks::Ref->new(validation => $validation);
        my $result = $o->check_for_ref($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'not ref',
            },
        ];
    };
};

subtest 'check_for_reftype()' => sub {
    plan tests => 3;

    subtest 'when document is not defined' => sub {
        plan tests => 2;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return undef;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                fail 'constraint_value is invoked';
                return 'ARRAY';
            },
        );

        my $o = JIP::Guard::Checks::Ref->new(validation => $validation);
        my $result = $o->check_for_reftype($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;
    };

    subtest 'when document is ARRAY' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return [42];
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 'ARRAY';
            },
        );

        my $o = JIP::Guard::Checks::Ref->new(validation => $validation);
        my $result = $o->check_for_reftype($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is not ARRAY' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'not ref';
            },
            record_error => qmeth {
                my ($self, %param) = @ARG;
                push @{ $errors }, \%param;
                return $self;
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 'ARRAY';
            },
        );

        my $o = JIP::Guard::Checks::Ref->new(validation => $validation);
        my $result = $o->check_for_reftype($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'not ref',
            },
        ];
    };
};

