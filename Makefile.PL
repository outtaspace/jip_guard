use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

my %write_makefile_param = (
    NAME             => 'JIP::Guard',
    AUTHOR           => q{Vladimir Zhavoronkov <flyweight@yandex.ru>},
    VERSION_FROM     => 'lib/JIP/Guard.pm',
    ABSTRACT_FROM    => 'lib/JIP/Guard.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.10.0,
    META_MERGE       => {
        'meta-spec'    => {version => 2},
        resources      => {
            license    => ['http://www.opensource.org/licenses/artistic-license-2.0'],
            bugtracker => {web => 'https://github.com/outtaspace/jip_guard/issues'},
            repository => {
                type => 'git',
                url  => 'https://github.com/outtaspace/jip_guard.git',
                web  => 'https://github.com/outtaspace/jip_guard',
            },
        },
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {},
    TEST_REQUIRES => {
        'English'         => 0,
        'Test::More'      => 0,
        'Test::Exception' => 0,
        'Test::NoTabs'    => 0,
        'lib::abs'        => 0,
        'Mock::Quick'     => 0,
    },
    PREREQ_PM => {
        'parent'            => 0,
        'Exporter'          => 0,
        'English'           => 0,
        'Carp'              => 0,
        'JIP::ClassField'   => '0.051',
        'Scalar::Util'      => 0,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
    clean => {FILES => 'JIP-Guard-*'},
);

unless (eval { ExtUtils::MakeMaker->VERSION(6.63_03); }) {
    $write_makefile_param{PREREQ_PM} = {
        %{ delete $write_makefile_param{'TEST_REQUIRES'} },
        %{ delete $write_makefile_param{'BUILD_REQUIRES'} },
    };
}

unless (eval { ExtUtils::MakeMaker->VERSION(6.52) }) {
    delete $write_makefile_param{'CONFIGURE_REQUIRES'};
}

WriteMakefile(%write_makefile_param);

