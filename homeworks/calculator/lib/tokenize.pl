=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

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

sub tokenize ($) {
chomp(my $expr = shift);
my $i;
my @res;
my $ch_str;
	for($i; $i < length $expr; $i++) { 
		$ch_str = substr $expr, $i, 1; # считывает очередной символ строки
		given ($ch_str) {
        		when (/^\s*$/) {} # пропустить, если пустая строка/пробелы
        		when (/\d/) { # элемент содержит цифру
				if ($#res == -1 or $res[-1] !~ /\d/) {
				my $ch;
				while($ch_str =~ /\d/) {
				$ch .= $ch_str;
				$i++;
				$ch_str = substr $expr, $i, 1;
				}
				
				push(@res,$ch);
				$i--;
				} else {die "Некорректное выражение(число): '$expr'";}
        		}
        		when ( '.' ) {
				#(Проходит 2.2.2!)
				#(Допилить, чтобы, если .5 превращалось в 0.5)
				if($#res ==-1) {die "Некорректное выражение(.): '$expr'";}
				elsif ($i<length $expr) {					
					$i++;
					$ch_str = substr $expr, $i, 1;
						while($ch_str eq ' ' and $i<length $expr) {$i++; $ch_str = substr $expr, $i, 1;}
					if($res[$#res] =~ (/[0-9]/) and $ch_str =~ /\d/){ 
						#если не последний символ, а следующий и предыдущий - цифры
						$res[$#res] .= ".";
						while($ch_str =~ /\d/ and $i<length $expr) {
							$res[$#res] .= $ch_str;
							$i++;
							$ch_str = substr $expr, $i, 1;
						}
						$i--;
						if($res[$#res] =~ /.0$/) {
							my $num = index $res[$#res], ".";
							$res[$#res] = substr $res[$#res], 0, $num;						
						}
					} elsif ($ch_str =~ /\d/) { 
						push(@res,'0.'.$ch_str);
						if($res[$#res] =~ /.0$/) {
							my $num = index $res[$#res], ".";
							$res[$#res] = substr $res[$#res], 0, $num;						
						}

					} else {
					die "Некорректное выражение(.): '$expr'";
					}
				} else {die "Некорректное выражение(.): '$expr'";}
			} 
        		when ([ '+','-','/','*']) {
					my $last;
					if(($i+1) < length  $expr) {
						$i++;				
						$last = substr $expr, $i, 1;
						while($last eq ' ' and $i < length  $expr) {$i++; $last = substr $expr, $i, 1;}
						$i--;

					if($last ne ')') {
						if ($res[$#res] =~ (/\d/) or 
							$res[$#res] eq ")") { 
 								push(@res,$ch_str);
						} elsif ($#res == -1 or $last eq '(' or $last =~ /\d/)
							{
							if ($ch_str eq '+') {
								push(@res,'U+');
							} elsif ($ch_str eq '-') {
								push(@res,'U-');
							}
						} else {die "Некорректное выражение (+,-,*,/): '$expr'";}
					} else {die "Некорректное выражение (+,-,*,/): '$expr'";}

				} else {die "Некорректное выражение (+,-,*,/): '$expr'";}
								
			}
			when (['^']) {
				if($res[$#res] =~ (/\d/)) {
					my $last;
					$i++;
					$last = substr $expr, $i, 1;
					while($last eq ' ') {$i++; $last = substr $expr, $i, 1;}
					$i--;	
					if($last =~ /\d/ or $last eq '-' or $last eq '+' or $last eq '(' or $last eq '.') {
						push(@res,$ch_str);
					} else {die "Неккоректное выражение (^): '$expr'";}
				}
			}
			when(['e','E']) {
				if ($res[$#res] =~ /\d/) {
					$i++;
					$ch_str = substr $expr, $i, 1;
					while($ch_str eq ' ') {$i++; $ch_str = substr $expr, $i, 1;}
					if($ch_str =~ /\d/ or $ch_str eq '+' or $ch_str eq '-') {
						$res[$#res] .= 'e'.$ch_str;
							$i++;
							$ch_str = substr $expr, $i, 1;
							while($ch_str =~ /\d/ and $i<length $expr) {
								$res[$#res] .= $ch_str;
								$i++;
								$ch_str = substr $expr, $i, 1;
							}
						$i--;
						#if ($res[$#res] =~ /0e*/ or $res[$#res] =~ /0E*/) {
						#	$res[$#res]  = 0;		
						#}
						$res[$#res] = 0 + $res[$#res];	
					} else {die "Неккоректное выражение (e): '$expr'";}
				} else {die "Неккоректное выражение (e): '$expr'";}
			}		
			when ([ '(',')']) {
					#(Проверка на парные скобки)
					push(@res,$ch_str);
				}
			
        		default {
            			die "Некорректный символ: '$_'";
        		}
		}

	}

	return \@res;
}

1;
