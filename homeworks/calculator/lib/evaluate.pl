=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {
	my $rpn = shift;
	my @res;
	my $i;
	my $el1; my $el2;
foreach my $el (@{$rpn}) {
	print "zzzzzzzzzzzzzz\n\n\n";
	if ($el =~ (/\d/)) {
		push(@res,$el);
	} elsif ($el eq 'U-') {
		$el1 = pop(@res);
		push(@res, '-'.$el1);
	} elsif ($el eq 'U+') {
		$el1 = pop(@res);
		push(@res, $el1);
	} 
	else {
		$el1 = pop(@res);
		$el2 = pop(@res);
		given($el)	 {
			when('+') {push(@res, $el2 + $el1); }			
			when('-') {push(@res, $el2 - $el1); }
			when('*') {push(@res, $el2 * $el1); }
			when('/') {push(@res, $el2 / $el1); }
			when('^') {push(@res, $el2 ** $el1); }
		}	
	}
	
} 
	return $res[0];
}

1;
