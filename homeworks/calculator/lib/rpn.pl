=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
use Data::Dumper;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";
#приоритет
sub prior {
	chomp(my $expr = shift);
	my $pr;
given($expr) {
	when('+') {$pr = 2;}
	when('-') {$pr = 2;}
	when('*') {$pr = 3;}
	when('/') {$pr = 3;}
	when('(') {$pr = 1;}
	when(')') {$pr = 1;}
	when('U-') {$pr = 5;}
	when('U+') {$pr = 5;}
	when('^') {$pr = 4;}
}
	return $pr;
}

sub rpn {
	my $expr = shift;
	my $res = tokenize($expr); #в $res храниться ссылка на массив
	my @rpn; #обратная польская нотация
	my @opr; #стек для операций
	my $out_in;
	#print Dumper(@res)."\n\n\n\n";

foreach my $el (@{$res}) {
	if ($el eq '(' || $el eq ')' || $el eq '+'|| $el eq '-'|| $el eq '*'|| $el eq '/' || $el eq '^' || $el eq 'U-' || $el eq 'U+') {	
		if ($el eq ')') {
			while($opr[-1] ne '(') {
				$out_in = pop(@opr);
				push(@rpn,$out_in);
			} 
			pop(@opr); #Удаляем "("
		} elsif($el eq '(') {
			push(@opr,$el);
		} elsif ($#opr == -1 || prior($opr[-1]) < prior($el)) {
			push(@opr,$el);
		} elsif (prior($opr[-1]) >= prior($el)) {		
			while(@opr && (prior($opr[-1]) >= $el) && $opr[-1] ne '(') {
				$out_in = pop(@opr);
				push(@rpn,$out_in);
			}
			push(@opr,$el);
		}
	} else {
		push(@rpn,$el);
	}
}

	# извлекаем оставшиеся символы в стеке
	while($#opr != -1) {
		$out_in = pop(@opr);
		push(@rpn,$out_in);
	}

	# извлекаем оставшиеся символы в стеке
	#push @rpn, reverse @opr;
#print Dumper(@rpn)."\n\n\n\n";
	return \@rpn;
}

1;
