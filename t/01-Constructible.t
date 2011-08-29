use strict;
use warnings;
use lib './lib/';
use Test::More; BEGIN{ 
  #check if maxima is installed on this machine
  plan skip_all => "Maxima needs to be installed on your system in order to test Constructible::Maxima"
    unless length((`whereis maxima`=~/\: (.*)$/)[0]) > 1;
};
use Constructible;
our $maxima;

our @p = ( [200,200] , [280,280] , [200,280],[280,200] ) ;# array of constructible points

sub test_leq {
    # Check if segment boundaries , the middle and one that is 1/4 of the length closer to $A and 3/4 of the length to $B
    # are in fact on the line
    my ($A,$B) = @_;

    my @xx = leq($A,$B);

    @xx = map { eval($_) } @xx;

    ok( $xx[0]* eval($_->[0]) + $xx[1]*eval($_->[1]) == $xx[2] , "line eq satisfied")
    for (
        $A,
        $B,
        line_middle($A,$B),
        line_ratio($A,$B,0.25),
    );
}
test_leq($p[0],$p[1]);


done_testing;
