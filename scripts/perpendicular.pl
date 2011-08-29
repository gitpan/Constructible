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
our $red;
use Constructible;

# bisector of angle p0p1p2

# until here the boilerplate is done
@p = ([200,180],[340,240]);



draw_line($p[0],$p[1]);

draw_circle($p[0],$p[1]);
draw_circle($p[1],$p[0]);

jam iCC(ceq($p[0],$p[1]),
        ceq($p[1],$p[0]));

jam iLL($p[2],$p[3],
        $p[0],$p[1]);

draw_line($p[2],$p[3]);

warn "~~P = ".~~@p;


for my $i (0..@p-1) {
    draw_point($p[$i],$i);
};

open my $stuff,">perpendicular.svg";
print $stuff $image->svg;
