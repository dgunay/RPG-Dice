# To test:
# - happy paths
# - bad paths
# - malicious expressions

use strict;
use warnings;

use RPG::Dice qw(
	tokenize_expression
	solve_dice_expression
);

# Receive expression
my $expr = $ARGV[0] or die usage();

# First split the expression into tokens
my @tokens = tokenize_expression($expr);

# Print the solution
print solve_dice_expression(\@tokens);

#################
# Subroutines
#################
sub usage {
	return "Usage: perl dice.pl [dice expression]";
}