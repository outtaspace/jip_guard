#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 4;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Registry', '0.01';
    require_ok 'JIP::Guard::Registry';

    diag(
        sprintf 'Testing JIP::Guard::Registry %s, Perl %s, %s',
            $JIP::Guard::Registry::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

subtest 'new()' => sub {
    plan tests => 3;

    my $o = JIP::Guard::Registry->new;
    ok $o, 'got instance of JIP::Guard::Registry';

    isa_ok $o, 'JIP::Guard::Registry';

    can_ok $o, qw(add extend remove clear get all);
};

subtest 'creating/reading/removing definitions' => sub {
    plan tests => 9;

    my $name       = 'foo';
    my $definition = 'foo definition';

    my $o = JIP::Guard::Registry->new;

    my $result = $o->get('foo');
    is $result, undef;

    $result = $o->get('bar');
    is $result, undef;

    $result = $o->add(foo => 'foo definition');
    is ref($result), ref($o);

    $result = $o->add(bar => 'bar definition');
    is ref($result), ref($o);

    $result = $o->get('foo');
    is $result, 'foo definition';

    $result = $o->get('bar');
    is $result, 'bar definition';

    $result = $o->remove(qw(foo bar));
    is ref($result), ref($o);

    $result = $o->get('foo');
    is $result, undef;

    $result = $o->get('bar');
    is $result, undef;
};

subtest 'bulk creating/reading/removing definitions' => sub {
    plan tests => 5;

    my $o = JIP::Guard::Registry->new;

    my %result = $o->all;
    is_deeply \%result, {};

    my $result = $o->extend(
        foo => 'foo definition',
        bar => 'bar definition',
    );
    is ref($result), ref($o);

    %result = $o->all;
    is_deeply \%result, {
        foo => 'foo definition',
        bar => 'bar definition',
    };

    $result = $o->clear;
    is ref($result), ref($o);

    %result = $o->all;
    is_deeply \%result, {};
};

