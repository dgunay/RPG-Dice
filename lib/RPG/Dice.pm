package RPG::Dice;

=pod

=head1 NAME

RPG::Dice -- Collection of subroutines that parse dice expressions.

=head1 SYNOPSIS
 
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

=head1 DESCRIPTION

This library parses RPG-style dice expressions. It ingests an arithmetic
expression such as '2d6 + 5', substitutes the result of rolling the die in-place,
and then evaluates the expression. So '2d6 + 5' might become '8 + 5', which
would obviously be 13.

=head1 SUBROUTINES

=cut

use strict;

our $VERSION = '1.0.0';

use Carp;
use Exporter qw(import);

our @EXPORT_OK = qw(
	tokenize_expression
	solve_dice_expression
	roll
	is_diceroll_token
	is_math_token
	is_valid_token
	is_int
);

=over 1

=item B<tokenize_expression( $expression )>

Parses a dice expression string into an array of tokens

=cut
sub tokenize_expression {
	my $expression = shift;
	my @tokens = split("", $expression);

	my @result = ();
	my $i = -1;

	my $dice = '';
	TOKENS: while ($i++ < (scalar @tokens - 1)) {
		my $char = $tokens[$i];

		next if $char eq ' '; # Skip spaces
		
		# Capture math tokens
		if (is_math_token($char)) {
			push @result, $char; 
			next;			
		}

		if ($char =~ /^(?:\d|d)$/) {
			# capture until non_diceroll
			while ($tokens[$i] =~ /^(?:\d|d)$/) {
				$dice .= $tokens[$i];
				$i++;
				last if $i >= (scalar @tokens);
			}
			$i--;

			push @result, $dice;
			$dice = '';
			last TOKENS if $i >= (scalar @tokens - 1);
			next;
		}

		die "Char $char is not a valid token";
	}
	
	# Validation
	foreach my $token (@result) {
		croak "'$token' is not a valid token" unless is_valid_token($token);
	}

	return @result;
}

=item B<solve_dice_expression( \@expression, $random_seed? )>

Solves a tokenized expression. Optionally a random seed can be provided for
deterministic results.

=cut
sub solve_dice_expression {
	my $tokens      = shift;
	my $random_seed = shift;

	croak 'Must be an ARRAY ref' unless ref $tokens eq 'ARRAY';

	my @expr = ();
	foreach my $token (@$tokens) {
		die "Token $token is invalid" unless is_valid_token($token);

		# Upon encountering a dice token (i.e. 2d6), roll it and capture the value
		push @expr, roll($token, $random_seed) if is_diceroll_token($token);

		# Otherwise store the token for basic math
		push @expr, $token if ( is_math_token($token) or is_int($token) );
	}

	my $arithmetic = join(" ", @expr);
	return eval $arithmetic;
}

=item B<roll( $dice_token, $random_seed? )>

Rolls a single dice token. If $random_seed is set, do be aware that it will
be passed to srand().

=cut
sub roll {
	my $dice_token  = shift;
	my $random_seed = shift // undef;

	# Makes rolls deterministic if the caller wants
	srand($random_seed) if $random_seed;

	my ($rolls, $sides) = is_diceroll_token($dice_token) 
		or croak "$dice_token is not a valid dice roll";

	my $total = 0;
	for my $i (1 .. $rolls) {
		$total += int(rand($sides)) + 1; # Random num between 1 and num sides
	}

	return $total;
}

=item B<is_diceroll_token( $token )>

Checks that the given token is of form [int]d[int], i.e. 2d6. Both the number
of rolls and the number of sides of the die can be captured as return values
like so:

	my ($num_rolls, $num_sides) = is_diceroll_token('2d6');>>

=cut
sub is_diceroll_token {
	my $token = shift;
	return ($1, $2) if $token =~ /^(\d+)d(\d+)$/;
	return 0;
}

=item B<is_math_token( $token )>

Checks that the given token is a math operator [+-*/] or a parens ().

=cut
sub is_math_token {
	my $token = shift;
	return $token =~ /^[\+\-*\/\(\)]$/;
}

=item B<is_valid_token( $token )>

Checks that the given token is any valid token (diceroll, math token, or int).

=cut
sub is_valid_token {
	my $token = shift;
	return (is_diceroll_token($token) or is_math_token($token) or is_int($token));
}

=item B<is_int( $token )>

Checks that the given token is an integer.

=cut
sub is_int {
	my $scalar = shift;
	return $scalar =~ /^\d+$/;
}

=back

=cut

1;