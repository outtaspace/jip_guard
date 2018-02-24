#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

use JIP::Guard;
use JIP::Guard::Registry;
use JIP::Guard::Definitions::String;

plan tests => 2;

my $guard = do {
    my $registry = build_registry();

    JIP::Guard->new(registry => $registry);
};

subtest 'validate first_name' => sub {
    plan tests => 3;

    $guard->validate(value => undef,  schema => 'first_name');
    $guard->validate(value => q{},    schema => 'first_name');
    $guard->validate(value => 'John', schema => 'first_name');

    is scalar(@{ $guard->errors }), 2;

    subtest 'first error' => sub {
        plan tests => 7;

        my $error = $guard->errors->[0];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'first_name';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'second error' => sub {
        plan tests => 7;

        my $error = $guard->errors->[1];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'first_name';
        is $error->document, q{};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'empty';
        is $definition->constraint_value, 0;
        is $definition->method,           'check_for_empty';
    };
};

subtest 'validate last_name' => sub {
    plan tests => 3;

    $guard->validate(value => undef, schema => 'last_name');
    $guard->validate(value => q{},   schema => 'last_name');
    $guard->validate(value => 'Doe', schema => 'last_name');

    is scalar(@{ $guard->errors }), 4;

    subtest 'third error' => sub {
        plan tests => 7;

        my $error = $guard->errors->[2];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'last_name';
        is $error->document, undef;

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'defined';
        is $definition->constraint_value, 1;
        is $definition->method,           'check_for_defined';
    };

    subtest 'fourth error' => sub {
        plan tests => 7;

        my $error = $guard->errors->[3];

        isa_ok $error, 'JIP::Guard::ValidationError';

        is $error->schema, 'last_name';
        is $error->document, q{};

        my $definition = $error->definition;

        isa_ok $definition, 'JIP::Guard::Definition';

        is $definition->constraint,       'empty';
        is $definition->constraint_value, 0;
        is $definition->method,           'check_for_empty';
    };
};

sub build_registry {
    my $registry = JIP::Guard::Registry->new;

    my $name = JIP::Guard::Definitions::String->new(
        defined    => 1,
        empty      => 0,
    );

    $registry->extend(
        'first_name' => $name,
        'last_name'  => $name,
    );
}

