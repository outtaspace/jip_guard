#!/usr/bin/env perl

use lib::abs qw(../lib);

use strict;
use warnings FATAL => 'all';

use Test::More;

plan skip_all => 'set TEST_NOTABS to enable this test (developer only!)'
    unless $ENV{'TEST_NOTABS'};

plan skip_all => 'Test::NoTabs required for this test!'
    unless eval 'use Test::NoTabs; 1';

all_perl_files_ok(
    lib::abs::path('.'),
    lib::abs::path('../lib'),
);

