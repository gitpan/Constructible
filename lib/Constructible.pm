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
use Constructible::Maxima;
use GD::SVG;
use Test::More;
use Math::Trig;
use List::AllUtils qw/any none/;
use feature ':5.10';
use Data::Dumper;
use Carp;
#ABSTRACT: Provides an interface to Maxima(full-featured CAS) as well as means to visualize and compute constructible numbers.
#use Devel::Size::Report qw/report_size/; # to measure size of a data structure

=head1 NAME

Constructible - A package for computing and visualizing constructible numbers.

=head1 VERSION

version 0.02

=cut



=head1 DESCRIPTION

This module provides the basic tools to build geometric constructions with ruler and compass. This is how constructible numbers arise, 
these are numbers  which can be constructed by initially taking 2 points and using only ruler and compass to build additional points, 
and those additional points must only be at intersections of either lines or circles drawn by means of ruler and compass.

This module also provides an interface to Maxima(which is a full-featured CAS).
Here are some examples:


=head2 construction of a perpendicular on a given segment

=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/constructible_png/perpendicular.png" /></center></p>

=end html

=head2 construction the parallel to a given segment

=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/constructible_png/parallel.png" /></center></p>

=end html

=head2 trisecting a segment

=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/constructible_png/trisect_segment.png" /></center></p>

=end html





=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Constructible_number>

L<Constructible::Maxima>

=cut

# Geometrical constructions
# -------------------------   

# This code is an early prototype

our $maxima = Constructible::Maxima->new;
$maxima->start_maxima;
$maxima->start_tcp_server;
$maxima->can_start->recv;

open my $debug_fh,">debug.log";



# CONSTRUCTIBLE NUMBERS
# ---------------------

#
#
# UPDATE : every point will be [x,y] with x,y strings which if evaluated give the coordinates in floating point fixed-precision

# the ideea would be to have a symbolic representation of the afixes of the points and
# compute them only when they are needed.

# point data structure arrayref with 3 positions
#
# first will indicate x coord
# second			  y coord


our @p = ( [200,200] , [280,280] , [200,280],[280,200] ) ;# array of constructible points

#keep a list with geometrical figures like
#
# (["circle",x_C,y_C,radius],["line",startx,starty,endx,endy])
#
#get new constructible points by intersections of all the existing figures
#
#
# because we don't have very good support for symbolic computation we'll just use strings and eval() for now.
# hopefuly there is some good free software out there that simplifies algebraic expressions containing constants
# and  +-*/ and sqrt.
#
# if there is none, we'll write some

our $image   = GD::SVG::Image->new(1000,500);


our $black = $image->colorAllocate(0,0,0);
our $blue  = $image->colorAllocate(0,0,255);
our $red   = $image->colorAllocate(255,0,0);



sub d {
	my ($P1,$P2) = @_;

  #$P1->[0] = $maxima->simplify($P1->[0]);
  #$P1->[1] = $maxima->simplify($P1->[1]);
  #$P2->[0] = $maxima->simplify($P2->[0]);
  #$P2->[1] = $maxima->simplify($P2->[1]);

  return $maxima->simplify(
    sprintf(
      " sqrt(( (%s) - (%s) )**2 + ( (%s) - (%s) )**2) ",
      $P1->[0],$P2->[0],
      $P1->[1],$P2->[1],
    )
  );
}


sub add_points {
    my ($a,$b) = @_;

}

sub half {
    sprintf("(%s)/2",$_[0]);
}


sub line_middle {
    my ($a,$b) = @_;

    return
    [
    sprintf("((%s)+(%s))/2",$a->[0],$b->[0]),
    sprintf("((%s)+(%s))/2",$a->[1],$b->[1]),
    ];
}


# INPUT: takes 2 points that define a line(segment actually)
# OUTPUT: the 2 points at the boundary of the screen that can be
#         reached if the line intersected them
sub biggest_line {
    my ($A,$B) = @_;

    my @P = map { eval($_) } @{$A};
    my @Q = map { eval($_) } @{$B};

    my @w = leq($A,$B);
    @w = map { eval($_) } @w;
    $w[2]*=-1;
    
}


# p = a*r + b*(1-r)
sub line_ratio {
    my ($a,$b,$r) = @_;

    return
    [
    sprintf("(%s)*($r)+(%s)*(1-$r)",$a->[0],$b->[0]),
    sprintf("(%s)*($r)+(%s)*(1-$r)",$a->[1],$b->[1]),
    ];
};



# simplify all coordinates in @p
sub flatten {
    @p = map {
      #warn "arg1=$_->[0]\n";
      #warn "arg2=$_->[1]\n";

      print $debug_fh "arg1=$_->[0]\n";
      print $debug_fh "arg2=$_->[1]\n";


      my $input1 = $_->[0];
      my $input2 = $_->[1];

      my $arg1_simplified = $maxima->simplify($_->[0]);
      my $arg2_simplified = $maxima->simplify($_->[1]);
      
      #warn "INPUT =$input1";
      #warn "RESULT=$arg1_simplified";
      #warn "INPUT =$input2";
      #warn "RESULT=$arg2_simplified";

      if(!defined($arg1_simplified) || !defined($arg2_simplified)) {
        warn "some value was undefined, can't go further";
        exit -1;
      };


      [
        $arg1_simplified,
        $arg2_simplified,
        #eval($_->[0]),
        #eval($_->[1]),
      ]
    } @p;
}



sub jam {
  # TODO: currently jam doesn't push points on @p if they're too close to other points already there
  # This is mainly because we don't want point labels superimposing, but the actual solution is to reposition
  # point labels instead of throwing out points.
  # Will reimplement this soon.

    my $eps = 2; # 


    BIG:for my $t ( @_ ) {
      if( none {  eval(d($t,$_)) <= $eps } @p ) {
        push @p,$t;
      };
    };


    #push @p,@_;
    flatten;
}


# draw a point
sub draw_point {
  print $debug_fh $_[0]->[0];
  print $debug_fh "\n\n";
  print $debug_fh $_[0]->[1];
  print $debug_fh "\n\n";

    my ($x,$y) = (
        eval($_[0]->[0]),
        eval($_[0]->[1]),
    );  

    $image->string(
        gdMediumBoldFont,
        $x-12,
        $y-12,
        'P'.$_[1],
        $red
    );
    $image->filledEllipse(
        $x,
        $y,
        4,
        4,
        $black,
    );
}



sub draw_line {
	my ($A,$B,$col) = @_;

	$image->line((map { eval($_) } (@$A,@$B)),$col//$blue);
}


# line equation
# INPUT : 2 points
# OUTPUT: a,b,c of the equation ax + by = c    as strings
sub leq {
	my ($a,$b) = @_;

	my @A = @$a;
	my @B = @$b;

	#  x   -A[0]    y   -A[1]
	#  ---------- = ---------       <=>
	#  A[0]-B[0]    A[1]-B[1]
	#
	#  
	#  x(A[1]-B[1]) - A[0](A[1]-B[1]) = y(A[0]-B[0]) - A[1](A[0]-B[0])
	#
	#  (A[1]-B[1]) x -(A[0]-B[0])y = A[0](A[1]-B[1]) - A[1](A[0]-B[0])
	#
	#     /\                /\                       /\
	#     ||                ||                       ||
	#      a                 b                        c
	

	my @ret =  
	(
		sprintf ("((%s) - (%s))", $A[1],$B[1]),
		sprintf ("(-((%s) - (%s)))", $A[0],$B[0]),
		sprintf ("((%s)*(%s-%s) - (%s)*(%s-%s))",
			$A[0],$A[1],$B[1],
			$A[1],$A[0],$B[0]),
	);

        #print map { eval($_)."\n" } @ret;
	
	print "\n\n";
	return @ret;
			
}


# return line equation of a parallel of a line L through a point P
sub parallel_leq {

}




# INPUT: 3 points   A,B,C
# OUTPUT: returns 1 point D so that  BD is the bisector of ABC
sub bisector_leq {
}

# INPUT : 3 points  A,B,C
# OUTPUT: returns 1 point so that BD is the median of AC and D sits on AC
sub median_leq {

}

# return points resulting from the intersection of 2 circles
# http://mathworld.wolfram.com/Circle-CircleIntersection.html
sub iCC {
    my (
        $x0,$y0,$r0,
        $x1,$y1,$r1,
    )= @_;

    warn Dumper \@_;

    my $dx = sprintf("((%s)-(%s))", $x1,$x0);
    my $dy = sprintf("((%s)-(%s))", $y1,$y0);

    my $d  = d([$x0,$y0],[$x1,$y1]);

    return 0
        if( 
            (eval($d) > (eval($r0) + eval($r1))     ) ||
            (eval($d) < abs(eval($r0) - eval($r1)   ) )
          );

    sub square {
        return sprintf("(%s)*(%s)",$_[0],$_[0]);
    };

    my $a =  sprintf(
        "(%s - %s + %s) / (2.0 * (%s))",
        square($r0),
        square($r1),
        square($d),
        $d,
    );

    my $x2 = sprintf(
        " (%s) + ((%s)*( (%s)/(%s) ))",
           $x0,    $dx,   $a,   $d
    );

    my $y2 = sprintf(
        " (%s) + ((%s)*( (%s)/(%s) ))",
           $y0,    $dy,   $a,   $d
    );

    my $h = sprintf("sqrt((%s)-(%s))",
                    square($r0),square($a)
    );


    my $rx = sprintf(" -(%s)*( (%s)/(%s) )",
                        $dy,     $h  , $d
    );

    my $ry = sprintf(" -(%s)*( (%s)/(%s) )",
                        $dx,     $h  , $d
    );

    my $xi = sprintf(" (%s) + (%s) ",
                        $x2 ,  $rx
                    );
    my $yi = sprintf(" (%s) - (%s) ",
                        $y2 ,  $ry
                    );

    my $xj = sprintf(" (%s) - (%s) ",
                        $x2 ,  $rx
                    );
    my $yj = sprintf(" (%s) + (%s) ",
                        $y2 ,  $ry
                    );

    return
    (
        [$xi,$yi],
        [$xj,$yj],
    );
}


# circle equation
# INPUT: 2 points
# OUTPUT: x0,y0,r of the equation   (x-x0)^2 + (y-y0)^2 = r^2
sub ceq {
	my ($a,$b) = @_;
	return
	(
		$a->[0],
		$a->[1],
		d($a,$b),
	);
}



# intersect line with other line 
# http://en.wikipedia.org/wiki/Line-line_intersection
sub iLL {
    my ($p1,$p2,$p3,$p4) = @_;

    #P(x,y)=
    #{
    #\frac{(x_1 y_2-y_1 x_2)(x_3-x_4)-(x_1-x_2)(x_3 y_4-y_3 x_4)}  {(x_1-x_2)(y_3-y_4)-(y_1-y_2)(x_3-x_4)},
    #\frac{(x_1 y_2-y_1 x_2)(y_3-y_4)-(y_1-y_2)(x_3 y_4-y_3 x_4)}  {(x_1-x_2)(y_3-y_4)-(y_1-y_2)(x_3-x_4)
    #}

    my $denom =
    sprintf(" ((%s)-(%s))*((%s)-(%s)) - ((%s)-(%s))*((%s)-(%s)) ",
               $p1->[0],$p2->[0],$p3->[1],$p4->[1],
               $p1->[1],$p2->[1],$p3->[0],$p4->[0],
           );

    my $num1  =
    sprintf(" ((%s)*(%s)-(%s)*(%s))*((%s)-(%s)) - ((%s)*(%s)-(%s)*(%s))*((%s)-(%s)) ",
               $p1->[0],$p2->[1],$p1->[1],$p2->[0],   $p3->[0],$p4->[0],
               $p3->[0],$p4->[1],$p3->[1],$p4->[0],   $p1->[0],$p2->[0],
           );

    my $num2  =
    sprintf(" ((%s)*(%s)-(%s)*(%s))*((%s)-(%s)) - ((%s)*(%s)-(%s)*(%s))*((%s)-(%s)) ",
               $p1->[0],$p2->[1],$p1->[1],$p2->[0],   $p3->[1],$p4->[1],
               $p3->[0],$p4->[1],$p3->[1],$p4->[0],   $p1->[1],$p2->[1],
           );

    [
    "(($num1)/($denom))",
    "(($num2)/($denom))",
    ];
}


sub iLC {
    my ($Ax,$Ay,
        $Bx,$By,
        $Cx,$Cy,$r) = @_;

    #http://mathworld.wolfram.com/Circle-LineIntersection.html

    #we'll shift the coordinate system to be centered in the center of the circle
    #but we'll keep in mind and shift back after we get the answer

    $Ax = "$Ax - ($Cx)";
    $Ay = "$Ay - ($Cy)";

    $Bx = "$Bx - ($Cx)";
    $By = "$By - ($Cy)";

    #($Cx,$Cy) = 0;

    my $D = sprintf(
        "((%s)*(%s) - (%s)*(%s))",
        $Ax,$By,
        $Ay,$Bx,
    );

    my $dx = sprintf("((%s) - (%s))",$Bx,$Ax);
    my $dy = sprintf("((%s) - (%s))",$By,$Ay);

    my $dr = d([$Ax,$Ay],[$Bx,$By]);

    my $delta =sprintf("(((%s)*(%s))**2 - ((%s)**2))",$r,$dr,$D);

    if(         eval($delta) > 0) {
        #intersection

        print "iLC: two intersection points\n";

        my $s = eval($dy)<=>0;
        my $x1 = sprintf(
            " ( ((%s)*(%s)) + (%s)*(    %s)*sqrt(%s) ) / ( (%s)**2 + (%s)**2  ) ",
                  $D,  $dy,   $s,$dx,$delta,         $dx,      $dy
        );
        my $y1 = sprintf(
            " ( -((%s)*(%s)) +      abs(%s)*sqrt(%s) ) / ( (%s)**2 + (%s)**2  ) ",
                  $D,  $dx,            $dy,$delta,         $dx,      $dy
        );

        my $x2 = sprintf(
            " ( ((%s)*(%s)) - (%s)*(    %s)*sqrt(%s) ) / ( (%s)**2 + (%s)**2  ) ",
                  $D,  $dy,   $s,$dx,$delta,         $dx,      $dy
        );
        my $y2 = sprintf(
            " ( -((%s)*(%s)) -      abs(%s)*sqrt(%s) ) / ( (%s)**2 + (%s)**2  ) ",
                  $D,  $dx,            $dy,$delta,         $dx,      $dy
        );

        $x1 = "($x1) + ($Cx)";
        $y1 = "($y1) + ($Cy)";


        $x2 = "($x2) + ($Cx)";
        $y2 = "($y2) + ($Cy)";

        return 
        (
            [$x1,$y1],
            [$x2,$y2],
        );

    } elsif (   eval($delta) ==0) {
        #tangent
        print "iLC: tangent\n";

        my $x1 = sprintf(
            " ( ((%s)*(%s)) ) / ( (%s)**2 + (%s)**2  ) ",
                  $D,  $dy,        $dx,      $dy
        );
        my $y1 = sprintf(
            " ( -((%s)*(%s))  ) / ( (%s)**2 + (%s)**2  ) ",
                  $D,  $dx,         $dx,      $dy
        );


        $x1 = "($x1) + ($Cx)";
        $y1 = "($y1) + ($Cy)";

        return ([$x1,$y1]);

    };

    return undef;
}


sub draw_circle2 {
    my ($C,$r) = @_;
    draw_circle($C,
        [
        sprintf("((%s)+(%s))",$C->[0],$r),
        $C->[1],
        ]
    );
}


sub draw_circle {

	my ($C,$S) = @_;# first one is the center and the second is a point on the circle

  confess 'Center of circle(first arg) not defined'
    if !defined $C;
  confess 'X coordinate of circle center not defined'
    if !$C->[0];
  confess 'Y coordinate of circle center not defined' 
    if !$C->[1];
  confess 'Argument S, point on circle, not defined'
    if !defined $S;

  warn "DRAW_CIRCLE()";
  warn Dumper \@_;
	my @c = ceq($C,$S);
  warn Dumper \@c;

	$image->ellipse(
		eval($c[0]),
		eval($c[1]),
		eval($c[2])*2,
		eval($c[2])*2,
		$blue
	);

}


# just check first what points are on it and then use that to
# draw small arcs containing those points
# purpose: simpler drawings
sub draw_circle_min {
    my ($C,$S) = @_;
    my @c = ceq($C,$S);

    my @w = map { eval($_) } @c; # x0,y0,r evaled

    my @points = grep  {
        (eval($_->[0])-$w[0])**2 + (eval($_->[1])-$w[1])**2 - $w[2]**2 <= 0.0001
    } @p; #points on circle

    for my $q ( @points ) {


        my $angle =

        ( $w[0] - eval($q->[0]) == 0)
        ? 0
        :   rad2deg
            atan( 
                 ( $w[1] - eval($q->[1]) )/
                 ( $w[0] - eval($q->[0]) )
            );

        $angle += 180;

        my $angle_left  = $angle - 10;
        my $angle_right = $angle + 10;

        $angle_left += 360 if $angle_left < 0  ;
        $angle_left -= 360 if $angle_left > 360;

        $angle_right += 360 if $angle_right < 0  ;
        $angle_right -= 360 if $angle_right > 360;

        ($angle_left ,$angle_right) = 
        ($angle_right,$angle_left ) if
                $angle_left > $angle_right;

        print "$angle_left     $angle_right\n";
        $image->arc($w[0],$w[1],$w[2]*2,$w[2]*2,int $angle_left,int $angle_right,$blue);

    };

}

sub draw_circle2_min {
    my ($C,$r) = @_;
    draw_circle_min($C,
        [
        sprintf("((%s)+(%s))",$C->[0],$r),
        $C->[1],
        ]
    );
}

sub draw_text {
  my ($x,$y,$color,$text) = @_;
  $image->string(
    gdSmallFont,
    $x,
    $y,
    $text,
    $color
  );
}


1;
