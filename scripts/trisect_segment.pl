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
our $image;
our @p;
our $black;
our $red;
use lib './lib';
use Constructible;

# The construction of a parallel of the line [p0,p1] through point p2,
#
# at the end of the construction the parallel will be [p2,p10]


# until here the boilerplate is done
@p = ([200,300],[300,350]);

draw_line($p[0],$p[1]);


draw_circle($p[0],$p[1]);
draw_circle($p[1],$p[0]);

jam iCC(ceq($p[0],$p[1]),
        ceq($p[1],$p[0]));



draw_line($p[0],$p[3]);


draw_circle($p[3],$p[0]);

jam iLC(@{$p[0]},@{$p[3]},ceq($p[3],$p[0]));

draw_line($p[4],$p[2]);


jam iLL($p[4],$p[2],$p[0],$p[1]);

# P5P1 = P0P1/3

draw_line($p[5],$p[1],$red);


for my $i (0..@p-1) {
    draw_point($p[$i],$i);
};



open my $stuff,">trisect_segment.svg";
print $stuff $image->svg;
