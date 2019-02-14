use strict;
use warnings;

use Test::More tests => 14;

use Data::Dumper;

use RPG::Dice qw(
	tokenize_expression
	solve_dice_expression
	roll
);

# Makes rolls deterministic
my $random_seed = 42;

# Test rolls are deterministic with the random seed
my @roll_pairs = (
	[roll('2d6',  $random_seed), roll('2d6',  $random_seed)],
	[roll('1d20', $random_seed), roll('1d20', $random_seed)],
	[roll('2d8',  $random_seed), roll('2d8',  $random_seed)],
	[roll('9d4',  $random_seed), roll('9d4',  $random_seed)],
	[roll('1d12', $random_seed), roll('1d12', $random_seed)],
);
foreach my $pair (@roll_pairs) {
	is($$pair[0], $$pair[1], 'Deterministic rolls');
}

# Tokenization tests
my %expr_tests = (
	# Test that expressions tokenize properly even with weird spacing
	'2d6+1d4'     => [qw/2d6 + 1d4/],
	'2d6 + 1d4'   => [qw/2d6 + 1d4/],
	'2d6  +  1d4' => [qw/2d6 + 1d4/],

	# Can it parse normal arithmetic?
	'5 + 5' => [qw/5 + 5/],
	'5 * 5' => [qw/5 * 5/],
	'5 * 5 + (2 - 2)' => [qw/5 * 5 + ( 2 - 2 )/],

	# Test that complex parens can be handled
	'2d6 + (1d4 + 1d4)'         => [qw/2d6 + ( 1d4 + 1d4 )/],
	'2d6 + (1d4 + (3d8 + 1d6))' => [qw/2d6 + ( 1d4 + ( 3d8 + 1d6 ) )/],
);
foreach my $expr (keys %expr_tests) {
	my $expected = $expr_tests{$expr};
	my @got = tokenize_expression($expr);
	is_deeply(\@got, $expected, $expr);
}

# Can it do basic math?
is(solve_dice_expression([qw/5 + 5/]), 10, '5 + 5 = 10');