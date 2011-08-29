use strict;
use warnings;
use lib './lib/';
use Test::More; BEGIN{ 
  #check if maxima is installed on this machine
  plan skip_all => "Maxima needs to be installed on your system in order to test Constructible::Maxima"
    unless length((`whereis maxima`=~/\: (.*)$/)[0]) > 1;
};
#use Endebugger;
use Constructible::Maxima;
my $c = Constructible::Maxima->new;
$c->start_maxima;
$c->start_tcp_server;
$c->can_start->recv;

## -> finished boilerplate here



is(
  $c->run_command_sync("1+1"),
  "2",
  "sync 1+1=2"
);

$c->run_command_async("string(integrate(sin(x)*x^5,x))",sub{
    is(
      $_[0],
      qw{(5*x**4-60*x**2+120)*sin(x)+(-x**5+20*x**3-120*x)*cos(x)},
      "async string(integrate(sin(x)*x^5,x)) ..."
    );
});


is(
  $c->run_command_sync("expand((1+x)^3)") ,
  "x**3+3*x**2+3*x+1",
  "sync expand((1+x)^3) = x**3+3*x**2+3*x+1"
);


is(
  $c->simplify("((1+sqrt(5))/2)^3"),
  "sqrt(5)+2",
  "simplify works well"
);


is(
  $c->simplify("( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) + ((((568)-(-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29)))*( ((( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) ) - ( sqrt(( (568) - (680) )**2 + ( (360) - (400) )**2) )*( sqrt(( (568) - (680) )**2 + ( (360) - (400) )**2) ) + ( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )) / (2.0 * ( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )))/( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) ) ))) + ( -(((360)-(-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29)))*( (sqrt((( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) ))-(((( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) ) - ( sqrt(( (568) - (680) )**2 + ( (360) - (400) )**2) )*( sqrt(( (568) - (680) )**2 + ( (360) - (400) )**2) ) + ( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )) / (2.0 * ( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )))*((( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (680) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (400) )**2) ) - ( sqrt(( (568) - (680) )**2 + ( (360) - (400) )**2) )*( sqrt(( (568) - (680) )**2 + ( (360) - (400) )**2) ) + ( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )*( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) )) / (2.0 * ( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) ))))))/( sqrt(( (-(16*sqrt(13)*sqrt(17)*sqrt(29)-19720)/29) - (568) )**2 + ( (-(40*sqrt(13)*sqrt(17)*sqrt(29)-11600)/29) - (360) )**2) ) ))"),
  "(946760*sqrt(13)*sqrt(17)*sqrt(29)-81354280)/(53*sqrt(13)*sqrt(17)*29**(3/2)-133661)",
  "simplify works ok with multiple-line output",
);



done_testing;
