use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Dancer::Session::SQLite',
    AUTHOR              => q{Puneet Kishor <punkish@eidesis.org>},
    VERSION_FROM        => 'lib/Dancer/Session/SQLite.pm',
    ABSTRACT_FROM       => 'lib/Dancer/Session/SQLite.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Dancer-Session-SQLite-*' },
);
