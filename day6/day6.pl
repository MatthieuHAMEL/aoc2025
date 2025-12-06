use strict;
use warnings;
use List::Util 'sum';

my @lines = <STDIN>; # perl day6.pl < input.txt
chomp @lines;

# last line contains the operators
my $op_line = pop @lines;
my @ops = split(' ', $op_line);

# '*' : start accumulating with 1 /// '+' : start with 0 
my @colres;
for my $i (0 .. $#ops) {
  $colres[$i] = $ops[$i] eq '*' ? 1 :  0;
}

# Process each data line
for my $line (@lines) {
  my @vals = split(' ', $line);
  for my $i (0 .. $#vals) {
    if ($ops[$i] eq '*') {
      $colres[$i] *= $vals[$i]
    }
    else { # ($ops[$i] eq '+')
      $colres[$i] += $vals[$i]
    }
  }
}

my $total = sum(@colres);
print "$total\n";
