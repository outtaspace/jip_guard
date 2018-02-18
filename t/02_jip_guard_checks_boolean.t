#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);
use Mock::Quick qw(qobj qmeth);

plan tests => 5;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Checks::Boolean', '0.01';
    require_ok 'JIP::Guard::Checks::Boolean';

    diag(
        sprintf 'Testing JIP::Guard::Checks::Boolean %s, Perl %s, %s',
            $JIP::Guard::Checks::Boolean::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 8;

    throws_ok {
        JIP::Guard::Checks::Boolean->new;
    }
    qr{Mandatory \s argument \s "validation" \s is \s missing}x;

    my $o = JIP::Guard::Checks::Boolean->new(validation => 'validation');
    ok $o, 'got instance of JIP::Guard::Checks::Boolean';

    isa_ok $o, 'JIP::Guard::Checks';
    isa_ok $o, 'JIP::Guard::Checks::Boolean';

    can_ok $o, qw(
        new
        validation
        schema
        document
        record_error
        check_for_defined
        check_for_boolean
        check_for_true
        check_for_false
        NEED_TO_CONTINUE
        NO_NEED_TO_CONTINUE
    );

    is $o->validation, 'validation';

    is $o->NEED_TO_CONTINUE,    1;
    is $o->NO_NEED_TO_CONTINUE, 0;
};

subtest 'check_for_boolean()' => sub {
    plan tests => 4;

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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_boolean($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;
    };

    subtest 'when document is boolean true' => sub {
        plan tests => 2;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 1;
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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_boolean($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is boolean false' => sub {
        plan tests => 2;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 0;
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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_boolean($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is not boolean' => sub {
        plan tests => 5;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'not boolean';
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
                return 1;
            },
        );

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_boolean($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'not boolean',
            },
        ];
    };
};

subtest 'check_for_true()' => sub {
    plan tests => 4;

    subtest 'true=1 and document=1' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 1;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 1;
            },
        );

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_true($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'true=1 and document=0' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 0;
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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_true($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 0,
            },
        ];
    };

    subtest 'true=0 and document=1' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 1;
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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_true($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 1,
            },
        ];
    };

    subtest 'true=0 and document=0' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 0;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 0;
            },
        );

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_true($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };
};

subtest 'check_for_false()' => sub {
    plan tests => 4;

    subtest 'false=1 and document=1' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 1;
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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_false($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 1,
            },
        ];
    };

    subtest 'false=1 and document=0' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 0;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 1;
            },
        );

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_false($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'false=0 and document=1' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 1;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 0;
            },
        );

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_false($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'false=0 and document=0' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 0;
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

        my $o = JIP::Guard::Checks::Boolean->new(validation => $validation);
        my $result = $o->check_for_false($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 0,
            },
        ];
    };
};

