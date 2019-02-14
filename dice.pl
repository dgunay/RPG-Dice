# To test:
# - happy paths
# - bad paths
# - malicious expressions

use strict;
use warnings;

use Data::Dumper;

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

# Parses a dice expression string into an array of tokens
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
	
	return @result;
}

sub trim {
	my $str = shift;
	$str =~ s/^\s+|\s+$//g;
	return $str;
}

# Solves a tokenized expression
sub solve_dice_expression {
	my $tokens = shift;

	my @expr = ();

	foreach my $token (@$tokens) {
		die "Token $token is invalid" unless is_valid_token($token);

		# Upon encountering a dice token (i.e. 2d6), roll it and capture the value
		push @expr, roll($token) if is_diceroll_token($token);

		# Otherwise store the token for basic math
		push @expr, $token if is_math_token($token);
	}

	return eval join("", @expr);
}

sub roll {
	my $dice_expr = shift;
	my ($num_rolls, $dice_type) = is_diceroll_token($dice_expr) 
		or die "$dice_expr is not a valid dice roll";

	my $total = 0;
	for my $i (1 .. $num_rolls) {
		$total += int(rand($dice_type)) + 1; # Random num between 1 and dice type
	}

	return $total;
}

# Is of standard dice roll format
sub is_diceroll_token {
	my $token = shift;
	return ($1, $2) if $token =~ /^(\d+)d(\d+)$/;
	return 0;
}

# Is an operator or parens
sub is_math_token {
	my $token = shift;
	return $token =~ /^[\+\-*\/\(\)]$/;
}

# Can't contain any tokens NOT in this character class
# (numbers, char d, +-/*, ())
sub is_valid_token {
	my $token = shift;
	return $token !~ /[^\dd\+\-*\/\(\)]/;
}

sub is_int {
	my $scalar = shift;
	return $scalar =~ /^\d+$/;
}