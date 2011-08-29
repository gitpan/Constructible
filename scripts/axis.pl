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
use Constructible;
# until here the boilerplate is done



#my @p = ( [200,200] , [280,280] , [200,280],[280,200] ) ;# array of constructible points
#draw_circle($p[0],$p[1]);
#draw_circle($p[1],$p[0]);

draw_circle($p[2],$p[3]);
draw_circle($p[3],$p[2]);

my @iC=
    iCC(
        ceq($p[2],$p[3]),
        ceq($p[3],$p[2]),
    );

push @p,@iC;
draw_line($p[-1],$p[-2]);
draw_line($p[2],$p[3]);

#draw_circle($p[5],$p[3]);


for my $i (0..@p-1) {
    draw_point($p[$i],$i);
};

open my $stuff,">axis.svg";
print $stuff $image->svg;
