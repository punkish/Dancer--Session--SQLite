#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Dancer::Session::SQLite' ) || print "Bail out!
";
}

diag( "Testing Dancer::Session::SQLite $Dancer::Session::SQLite::VERSION, Perl $], $^X" );
