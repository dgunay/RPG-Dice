use strict;
use warnings;

use Test::More tests => 18;

use RPG::Dice qw(
	is_diceroll_token
	is_math_token
);

# Test our dice roll validations
my @dice_rolls = ('1d4', '2d6', '3d7', '1d20', '5000d123878');
ok(is_diceroll_token($_), "$_ is a dice roll") for @dice_rolls;

# Math tokens aren't dice rolls
my @not_dice_rolls = ('+', '-', '*', '/');
is(is_diceroll_token($_), 0, "$_ is not a a dice roll") for @not_dice_rolls;

# Janky stuff
my @malformed_rolls = ('2d6+', '2d6 ', ' 2d6');
is(is_diceroll_token($_), 0, "$_ is a malformed dice roll") for @malformed_rolls;

# Test our math token validations
my @math_tokens = ('+', '-', '*', '/', '(', ')');
ok(is_math_token($_), "$_ is a math token") for @math_tokens;