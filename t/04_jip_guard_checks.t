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

    use_ok 'JIP::Guard::Checks', '0.01';
    require_ok 'JIP::Guard::Checks';

    diag(
        sprintf 'Testing JIP::Guard::Checks %s, Perl %s, %s',
            $JIP::Guard::Checks::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 7;

    throws_ok {
        JIP::Guard::Checks->new;
    }
    qr{Mandatory \s argument \s "validation" \s is \s missing}x;

    my $o = JIP::Guard::Checks->new(validation => 'validation');
    ok $o, 'got instance of JIP::Guard::Checks';

    isa_ok $o, 'JIP::Guard::Checks';

    can_ok $o, qw(
        new
        validation
        schema
        document
        record_error
        check_for_defined
        NEED_TO_CONTINUE
        NO_NEED_TO_CONTINUE
    );

    is $o->validation, 'validation';

    is $o->NEED_TO_CONTINUE,    1;
    is $o->NO_NEED_TO_CONTINUE, 0;
};

subtest 'schema()' => sub {
    plan tests => 2;

    my $validation = qobj(
        schema => qmeth {
            pass 'schema is invoked';
            return 'validation schema';
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    is $o->schema, 'validation schema';
};

subtest 'document()' => sub {
    plan tests => 2;

    my $validation = qobj(
        document => qmeth {
            pass 'document is invoked';
            return 'validation document';
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    is $o->document, 'validation document';
};

subtest 'record_error()' => sub {
    plan tests => 3;

    my $errors = [];

    my $validation = qobj(
        schema => qmeth {
            return 'validation schema';
        },
        document => qmeth {
            return 'validation document';
        },
        record_error => qmeth {
            my ($self, %param) = @ARG;
            push @{ $errors }, \%param;
            return $self;
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    $o = $o->record_error(xarg => 'xarg value');
    isa_ok $o, 'JIP::Guard::Checks';

    is_deeply $errors, [
        {
            schema   => 'validation schema',
            document => 'validation document',
            xarg     => 'xarg value',
        },
    ];

    $errors = [];
    $o = $o->record_error(
        xarg     => 'other xarg value',
        schema   => 'other schema',
        document => 'other document',
    );
    is_deeply $errors, [
        {
            schema   => 'validation schema',
            document => 'validation document',
            xarg     => 'other xarg value',
        },
    ];
};

subtest 'check_for_defined() when defined=1 and document is defined' => sub {
    plan tests => 4;

    my $errors = [];

    my $validation = qobj(
        schema => qmeth {
            fail 'schema is invoked';
            return 'validation schema';
        },
        document => qmeth {
            pass 'document is invoked';
            return 'document is defined';
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
            return 1;
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    my $result = $o->check_for_defined($definition);
    is $result, $o->NEED_TO_CONTINUE;

    is_deeply $errors, [];
};

subtest 'check_for_defined() when defined=1 and document is undefined' => sub {
    plan tests => 6;

    my $errors = [];

    my $validation = qobj(
        schema => qmeth {
            pass 'schema is invoked';
            return 'validation schema';
        },
        document => qmeth {
            pass 'document is invoked';
            return undef;
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
            return 1;
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    my $result = $o->check_for_defined($definition);
    is $result, $o->NO_NEED_TO_CONTINUE;

    is_deeply $errors, [
        {
            schema     => 'validation schema',
            definition => $definition,
            document   => undef,
        },
    ];
};

subtest 'check_for_defined() when defined=0 and document is defined' => sub {
    plan tests => 6;

    my $errors = [];

    my $validation = qobj(
        schema => qmeth {
            pass 'schema is invoked';
            return 'validation schema';
        },
        document => qmeth {
            pass 'document is invoked';
            return 'document is defined';
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
            return 0;
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    my $result = $o->check_for_defined($definition);
    is $result, $o->NO_NEED_TO_CONTINUE;

    is_deeply $errors, [
        {
            schema     => 'validation schema',
            definition => $definition,
            document   => 'document is defined',
        },
    ];
};

subtest 'check_for_defined() when defined=0 and document is undefined' => sub {
    plan tests => 4;

    my $errors = [];

    my $validation = qobj(
        schema => qmeth {
            fail 'schema is invoked';
            return 'validation schema';
        },
        document => qmeth {
            pass 'document is invoked';
            return undef;
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
            return 0;
        },
    );

    my $o = JIP::Guard::Checks->new(validation => $validation);

    my $result = $o->check_for_defined($definition);
    is $result, $o->NEED_TO_CONTINUE;

    is_deeply $errors, [];
};

