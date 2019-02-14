# To test:
# - happy paths
# - bad paths
# - malicious expressions

use strict;
use warnings;

use RPG::Dice;

# Receive expression
my $expr = $ARGV[0] or die usage();

# First split into tokens on spaces, operators, and parens
# i.e. 4d6+2d4 won't split into (4d6 + 2d4)
my @tokens = tokenize_expression($expr);

# Join and eval
print solve_dice_expression(\@tokens);

#################
# Subroutines
#################
sub usage {
	return "Usage: perl dice.pl [dice expression]";
}