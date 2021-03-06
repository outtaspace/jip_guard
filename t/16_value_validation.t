#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Exception;
use English qw(-no_match_vars);

use JIP::Guard;
use JIP::Guard::Registry;
use JIP::Guard::Definitions::String;
use JIP::Guard::Definitions::Boolean;
use JIP::Guard::Definitions::Count;
use JIP::Guard::Definitions::Integer;
use JIP::Guard::Definitions::Float;
use JIP::Guard::Definitions::Ref;

plan tests => 9;

my $guard = do {
    my $registry = build_registry();

    JIP::Guard->new(registry => $registry);
};

subtest 'validate first_name' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'first_name');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'first_name';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is empty string' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => q{}, schema => 'first_name');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'first_name';
        is $error->document, q{};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'empty';
        is $definition->constraint_value, 0;
        is $definition->method,           'check_for_empty';
    };

    subtest 'value is non empty string' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => 'John', schema => 'first_name');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'validate last_name' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'last_name');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'last_name';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is empty string' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => q{}, schema => 'last_name');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'last_name';
        is $error->document, q{};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'empty';
        is $definition->constraint_value, 0;
        is $definition->method,           'check_for_empty';
    };

    subtest 'value is non empty string' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => 'Doe', schema => 'last_name');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'validate is_boolean' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'is_boolean');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'is_boolean';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is not boolean' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => 100500, schema => 'is_boolean');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'is_boolean';
        is $error->document, 100500;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'boolean';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_boolean';
    };

    subtest 'value is boolean' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => 1, schema => 'is_boolean');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'validate user_id' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'user_id');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'user_id';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is not a count' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => -100500, schema => 'user_id');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'user_id';
        is $error->document, -100500;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'count';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_count';
    };

    subtest 'value is a count' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => 100500, schema => 'user_id');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'validate multiplier' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'multiplier');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'multiplier';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is not integer' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => 100.5, schema => 'multiplier');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'multiplier';
        is $error->document, 100.5;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'integer';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_integer';
    };

    subtest 'value is integer' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => 100, schema => 'multiplier');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'validate amount' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'amount');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'amount';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is not float' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => q{}, schema => 'amount');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'amount';
        is $error->document, q{};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'float';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_float';
    };

    subtest 'value is float' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => 100.5, schema => 'amount');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'validate items' => sub {
    plan tests => 3;

    subtest 'value is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => undef, schema => 'items');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'items';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'value is not a reference' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => q{}, schema => 'items');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'items';
        is $error->document, q{};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'ref';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_ref';
    };

    subtest 'value is a reference' => sub {
        plan tests => 3;

        my $pass = $guard->validate(document => [], schema => 'items');

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

subtest 'throwable mode' => sub {
    plan tests => 2;

    $guard->set_throwable(1);

    subtest 'throwable is requested' => sub {
        plan tests => 10;

        my ($line, $pass);
        eval {
            $line = __LINE__; $pass = $guard->validate(
                document => q{},
                schema   => 'items',
            );
        };

        is $pass, undef;

        if ($@) {
            my $error_handler = $@;

            isa_ok $error_handler, 'JIP::Guard::BaseErrorHandler';

            ok $error_handler->has_error;

            is scalar @{ $error_handler->errors },  1;

            my $error = $error_handler->errors->[0];

            isa_ok $error, 'JIP::Guard::ValidationError';

            is $error->schema,   'items';
            is $error->document, q{};

            isa_ok $error->trace, 'Devel::StackTrace';

            my $first_frame = $error->trace->frame(0);

            is $first_frame->package, __PACKAGE__;
            is $first_frame->line,    $line;
        }
    };

    $guard->set_throwable(0);

    subtest 'after throwable is disabled' => sub {
        plan tests => 9;

        my $line = __LINE__; my $pass = $guard->validate(
            document => q{},
            schema   => 'items',
        );

        is $pass, 0;

        ok $guard->has_error;

        is scalar @{ $guard->errors },  1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema,   'items';
        is $error->document, q{};

        isa_ok $error->trace, 'Devel::StackTrace';

        my $first_frame = $error->trace->frame(0);

        is $first_frame->package, __PACKAGE__;
        is $first_frame->line,    $line;
    };
};

subtest 'validate() if schema is not exists' => sub {
    plan tests => 1;

    throws_ok { $guard->validate(document => q{}, schema => 'tratata'); } qr{
        No \s definitions \s found \s for \s "tratata"
    }x;
};

sub build_registry {
    my $registry = JIP::Guard::Registry->new;

    {
        my $name = JIP::Guard::Definitions::String->new(
            defined    => 1,
            empty      => 0,
        );

        $registry->extend(
            'first_name' => $name,
            'last_name'  => $name,
        );
    }
    {
        my $defined_boolean = JIP::Guard::Definitions::Boolean->new(
            defined => 1,
        );

        $registry->add(is_boolean => $defined_boolean);
    }
    {
        my $defined_count = JIP::Guard::Definitions::Count->new(
            defined => 1,
        );

        $registry->add(user_id => $defined_count);
    }
    {
        my $defined_integer = JIP::Guard::Definitions::Integer->new(
            defined => 1,
        );

        $registry->add(multiplier => $defined_integer);
    }
    {
        my $defined_float = JIP::Guard::Definitions::Float->new(
            defined => 1,
        );

        $registry->add(amount => $defined_float);
    }
    {
        my $defined_array_ref = JIP::Guard::Definitions::Ref->new(
            defined => 1,
            reftype => 'ARRAY',
        );

        $registry->add(items => $defined_array_ref);
    }
}

