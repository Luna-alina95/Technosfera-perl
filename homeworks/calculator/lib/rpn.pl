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
	my @res = tokenize($expr);
	my @rpn; #обратная польская нотация
	my @opr; #стек для операций
	my $out_in;
	my $i;
	
for($i=0; $i<=$#res; $i++) { #Рассматриваем поочередно каждый символ:	
	if ($res[$i] eq '(' || $res[$i] eq ')' || $res[$i] eq '+'|| $res[$i] eq '-'|| $res[$i] eq '*'|| $res[$i] eq '/' || $res[$i] eq '^' || $res[$i] eq 'U-' || $res[$i] eq 'U+') {	

		if ($res[$i] eq ')') {
			while($opr[-1] ne '(') {
				$out_in = pop(@opr);
				push(@rpn,$out_in);
			} 
			pop(@opr); #Удаляем "("
		} elsif($res[$i] eq '(') {
			push(@opr,$res[$i]);
		} elsif ($#opr == -1 || prior($opr[-1]) < prior($res[$i])) {
			push(@opr,$res[$i]);
		} elsif (prior($opr[-1]) >= prior($res[$i])) {		
			while(@opr && (prior($opr[-1]) >= $res[$i]) && $opr[-1] ne '(') {
				$out_in = pop(@opr);
				push(@rpn,$out_in);
			}
			push(@opr,$res[$i]);
		} 
	} else {
		push(@rpn,$res[$i]);
	}
	
} 
	# извлекаем оставшиеся символы в стеке
	while($#opr != -1) {
		$out_in = pop(@opr);
		push(@rpn,$out_in);
	}

	# извлекаем оставшиеся символы в стеке
	#push @rpn, reverse @opr;

	return \@rpn;
}

1;
