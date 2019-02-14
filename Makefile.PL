use strict;
use warnings;
 
# Not sure if we really need this
# use 5.008;
 
use ExtUtils::MakeMaker;
WriteMakefile
(
  NAME         => 'RPG::Dice',
  VERSION_FROM => 'lib/RPG/Dice.pm',
  EXE_FILES    => [ qw(bin/dice) ],
);