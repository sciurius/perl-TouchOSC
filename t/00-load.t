#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'TouchOSC' );
}

diag( "Testing TouchOSC $TouchOSC::VERSION, Perl $], $^X" );
