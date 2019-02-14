# RPG-Dice

Perl library and script that can perform compound dice roll expressions.

It can do arithmetic such as `2d6 + 5` or `1d8 + (2d6 * 1d20)`. For example, if 
you use `bin/dice`:

```
dice expression [random_seed]
```

## Why?

It seemed like both an interesting enough problem to be fun to solve, but also 
an easy enough one that it would make it a good candidate for learning how to 
make a standard Perl package.

Ok, on with the POD.

## NAME
  
RPG::Dice -- Collection of subroutines that parse dice expressions.

## SYNOPSIS

```perl
use RPG::Dice qw(
	tokenize_expression
	solve_dice_expression
	roll
)

# Parse an expression into an array of tokens
my @tokens = tokenize_expression('1d4 + 8');

# Prints some number between 9 and 12 inclusive
print solve_dice_expression(\@tokens);

# Get the result of a single dice roll
my $result = roll('2d6');
```

## DESCRIPTION

This library parses RPG-style dice expressions. It ingests an arithmetic
expression such as '2d6 + 5', substitutes the result of rolling the die
in-place, and then evaluates the expression. So `'2d6 + 5'` might become 
`'8 + 5'`, which would obviously be `13`.

## SUBROUTINES

### `tokenize_expression( $expression )`
- Parses a dice expression string into an array of tokens

### `solve_dice_expression( \@expression, $random_seed? )`
- Solves a tokenized expression. Optionally a random seed can be provided
for deterministic results.

### `roll( $dice_token, $random_seed? )`
- Rolls a single dice token. If $random_seed is set, do be aware that it
will be passed to srand().

### `is_diceroll_token( $token )`
- Checks that the given token is of form [int]d[int], i.e. 2d6. Both the
number of rolls and the number of sides of the die can be captured as
return values like so:

```perl
my ($num_rolls, $num_sides) = is_diceroll_token('2d6');
```

### `is_math_token( $token )`
- Checks that the given token is a math operator [+-*/] or a parens ().

### `is_valid_token( $token )`
- Checks that the given token is any valid token (diceroll, math token, or
int).

### `is_int( $token )`
- Checks that the given token is an integer.

