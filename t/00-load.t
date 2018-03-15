use 5.006;
use strict;
use warnings;
use Test::More;
 
plan tests => 1;
 
BEGIN {
    use_ok( 'AnyEvent::Connector' ) || print "Bail out!\n";
}
 
diag( "Testing AnyEvent::Connector $AnyEvent::Connector::VERSION, Perl $], $^X" );
