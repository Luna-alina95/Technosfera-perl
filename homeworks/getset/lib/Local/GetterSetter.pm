{
package lib::newmodul;

use strict;
use warnings;
use Data::Dumper; 
sub import {
	my ($class, @vars) = @_;
	my ($package, $filename, $line) = caller();
	foreach my $k (@vars) {
		no strict 'refs';
		*{$package.'::'."set_$k"} = sub {
			${$package.'::'.$k} = shift;
		};
		
		*{$package.'::'."get_$k"} = sub {
		  	return ${$package.'::'.$k};
		};
	}
}
1;
}
