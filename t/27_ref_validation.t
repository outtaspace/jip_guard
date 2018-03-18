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
use JIP::Guard::Definitions::HashElement;

plan tests => 1;

my $guard = do {
    my $registry = build_registry();

    JIP::Guard->new(registry => $registry);
};

subtest 'validate first_name' => sub {
    plan tests => 5;

    subtest 'document is not defined' => sub {
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

        is $definition->constraint,       'hash_element';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_hash_element';
    };

    subtest 'element does not exist in document' => sub {
        plan tests => 10;

        my $pass = $guard->validate(document => {}, schema => 'first_name');

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'first_name';

        is_deeply $error->document, {};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'required';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_required';
    };

    subtest 'element is not defined' => sub {
        plan tests => 10;

        my $pass = $guard->validate(
            document => {first_name => undef},
            schema   => 'first_name',
        );

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'first_name';

        is_deeply $error->document, {first_name => undef};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'schema';
        is $definition->constraint_value, 'name';
        is $definition->method,           'check_for_schema';
    };

    subtest 'element is empty string' => sub {
        plan tests => 10;

        my $pass = $guard->validate(
            document => {first_name => q{}},
            schema   => 'first_name',
        );

        is $pass,             0;
        is $guard->has_error, 1;

        is scalar(@{ $guard->errors }), 1;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'first_name';

        is_deeply $error->document, {first_name => q{}};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'schema';
        is $definition->constraint_value, 'name';
        is $definition->method,           'check_for_schema';
    };

    subtest 'element is valid "name"' => sub {
        plan tests => 3;

        my $pass = $guard->validate(
            document => {first_name => q{John}},
            schema   => 'first_name',
        );

        is $pass,             1;
        is $guard->has_error, 0;

        is scalar(@{ $guard->errors }), 0;
    };
};

sub build_registry {
    my $registry = JIP::Guard::Registry->new;

    {
        my $name = JIP::Guard::Definitions::String->new(
            defined    => 1,
            empty      => 0,
        );

        my $first_name = JIP::Guard::Definitions::HashElement->new(
            required => 1,
            schema   => 'name',
        );

        $registry->extend(
            name       => $name,
            first_name => $first_name,
        );
    }
}

