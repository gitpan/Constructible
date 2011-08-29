#!/usr/bin/perl
#
# This file is part of Constructible
#
# This software is copyright (c) 2011 by Stefan Petrea.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
use warnings;
use strict;
use warnings;
use lib './lib';
our $image;
our @p;
our $black;
our $blue;
our $red;
use Constructible;

#TODO: check

# The construction of a parallel of the line [p0,p1] through point p2,
#
# at the end of the construction the parallel will be [p2,p10]




@p = ([100,300],[380,400],[300,200]);

draw_line($p[0],$p[1]);

push @p,line_ratio($p[0],$p[1],0.7);

draw_line($p[2],$p[3]);

push @p,line_ratio($p[3],$p[2],0.4);

draw_circle($p[3],$p[4]);

push @p,iLC(@{$p[0]},@{$p[1]},ceq($p[3],$p[4]));

push @p,
iLC(
    @{$p[3]},@{$p[2]},
    (@{$p[2]},d($p[3],$p[4]))
);

draw_circle( $p[2],$p[8]);
draw_circle2($p[8],d($p[4],$p[5]));

push @p,iCC(
    @{$p[8]},d($p[4],$p[5]),
    ceq($p[2],$p[8])
);

draw_line($p[2],$p[10]);


#push @p,iLC(@{$p[3]},@{$p[2]},(@{$p[2]},d($p[3],$p[4])));

open my $fh,">expr.txt" ; print $fh $p[-1]->[0];

for my $i (0..@p-1) {
    draw_point($p[$i],$i);
};


draw_text(
    350,
    300,
    $black,
    "P2P10 is the parallel of P0P1 through P2 so ==> P0P1 || P2P10",
);


open my $stuff,">parallel.svg";
print $stuff $image->svg;
