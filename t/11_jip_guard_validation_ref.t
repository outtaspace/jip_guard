#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;
use English qw(-no_match_vars);

plan tests => 1;

subtest 'Require some module' => sub {
    plan tests => 2;

    use_ok 'JIP::Guard::Validation::Ref', '0.01';
    require_ok 'JIP::Guard::Validation::Ref';

    diag(
        sprintf 'Testing JIP::Guard::Validation::Ref %s, Perl %s, %s',
            $JIP::Guard::Validation::Ref::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );
};

