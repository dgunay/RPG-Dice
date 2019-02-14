package RPG::Dice;

use strict;

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
	
	# Validation
	foreach my $token (@result) {
		croak "'$token' is not a valid token" unless is_valid_token($token);
	}

	return @result;
}

# Solves a tokenized expression
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

# Rolls a single dice token. If $random_seed is set, do be aware that it will
# be passed to srand().
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

# Is of standard dice roll format (i.e. 2d6)
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

sub is_valid_token {
	my $token = shift;
	return (is_diceroll_token($token) or is_math_token($token) or is_int($token));
}

sub is_int {
	my $scalar = shift;
	return $scalar =~ /^\d+$/;
}

1;