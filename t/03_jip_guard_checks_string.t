#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);
use Mock::Quick qw(qobj qmeth);

plan tests => 9;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Checks::String', '0.01';
    require_ok 'JIP::Guard::Checks::String';

    diag(
        sprintf 'Testing JIP::Guard::Checks::String %s, Perl %s, %s',
            $JIP::Guard::Checks::String::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 8;

    throws_ok {
        JIP::Guard::Checks::String->new;
    }
    qr{Mandatory \s argument \s "validation" \s is \s missing}x;

    my $o = JIP::Guard::Checks::String->new(validation => 'validation');
    ok $o, 'got instance of JIP::Guard::Checks::String';

    isa_ok $o, 'JIP::Guard::Checks';
    isa_ok $o, 'JIP::Guard::Checks::String';

    can_ok $o, qw(
        new
        validation
        schema
        document
        record_error
        check_for_defined
        check_for_string
        check_for_in
        check_for_min_length
        check_for_max_length
        check_for_empty
        check_for_like
        check_for_verify
        NEED_TO_CONTINUE
        NO_NEED_TO_CONTINUE
    );

    is $o->validation, 'validation';

    is $o->NEED_TO_CONTINUE,    1;
    is $o->NO_NEED_TO_CONTINUE, 0;
};

subtest 'check_for_string()' => sub {
    plan tests => 3;

    subtest 'when document is not defined' => sub {
        plan tests => 3;

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
                pass 'constraint_value is invoked';
                return 1;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_string($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is not a string' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return [];
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

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_string($definition);
        is $result, $o->NO_NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => [],
            },
        ];
    };

    subtest 'when document is a string' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'a string';
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

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_string($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };
};

subtest 'check_for_in()' => sub {
    plan tests => 3;

    subtest 'when document is not defined and in list' => sub {
        plan tests => 3;

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
                pass 'constraint_value is invoked';
                return ['foo', 'bar', undef, 'wtf'];
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_in($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is defined and in list' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return ['foo', 'bar', undef, 'wtf'];
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_in($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when document is defined and not in list' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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
                return ['foo', 'bar', 'baz'];
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_in($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'wtf',
            },
        ];
    };
};

subtest 'check_for_min_length()' => sub {
    plan tests => 2;

    subtest 'pass validation' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 3;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_min_length($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'fail validation' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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
                return 4;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_min_length($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'wtf',
            },
        ];
    };
};

subtest 'check_for_max_length()' => sub {
    plan tests => 2;

    subtest 'pass validation' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return 3;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_max_length($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'fail validation' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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
                return 2;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_max_length($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'wtf',
            },
        ];
    };
};

subtest 'check_for_empty()' => sub {
    plan tests => 4;

    subtest 'when empty=0 and string is empty' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return q{};
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

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_empty($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => q{},
            },
        ];
    };

    subtest 'when empty=0 and string is not empty' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_empty($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when empty=1 and string is empty' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return q{};
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

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_empty($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'when empty=1 and string is not empty' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_empty($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'wtf',
            },
        ];
    };
};

subtest 'check_for_like()' => sub {
    plan tests => 2;

    subtest 'pass validation' => sub {
        plan tests => 3;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 42;
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';
                return qr{^\d+$}x;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_like($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'fail validation' => sub {
        plan tests => 6;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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
                return qr{^\d+$}x;
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_like($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'wtf',
            },
        ];
    };
};

subtest 'check_for_verify()' => sub {
    plan tests => 2;

    subtest 'pass validation' => sub {
        plan tests => 4;

        my $validation = qobj(
            schema => qmeth {
                fail 'schema is invoked';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
            },
            record_error => qmeth {
                fail 'record_error is invoked';
            },
        );

        my $definition = qobj(
            constraint_value => qmeth {
                pass 'constraint_value is invoked';

                return sub {
                    my ($self) = @ARG;

                    isa_ok $self, 'JIP::Guard::Checks::String';

                    return 1;
                };
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_verify($definition);
        is $result, $o->NEED_TO_CONTINUE;
    };

    subtest 'fail validation' => sub {
        plan tests => 7;

        my $errors = [];

        my $validation = qobj(
            schema => qmeth {
                pass 'schema is invoked';
                return 'validation schema';
            },
            document => qmeth {
                pass 'document is invoked';
                return 'wtf';
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

                return sub {
                    my ($self) = @ARG;

                    isa_ok $self, 'JIP::Guard::Checks::String';

                    return 0;
                };
            },
        );

        my $o = JIP::Guard::Checks::String->new(validation => $validation);
        my $result = $o->check_for_verify($definition);
        is $result, $o->NEED_TO_CONTINUE;

        is_deeply $errors, [
            {
                schema     => 'validation schema',
                definition => $definition,
                document   => 'wtf',
            },
        ];
    };
};

