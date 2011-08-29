
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Provides an interface to Maxima(full-featured CAS) as well as means to visualize and compute constructible numbers.",
  "AUTHOR" => "Stefan Petrea <randomcoder1\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Constructible",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Constructible",
  "PREREQ_PM" => {
    "AnyEvent" => "6.02",
    "AnyEvent::Handle" => 0,
    "AnyEvent::Socket" => 0,
    "Carp" => 0,
    "GD::SVG" => "0.33",
    "List::AllUtils" => "0.02",
    "Moose" => "2.0010",
    "Test::More" => 0
  },
  "VERSION" => "0.02",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



