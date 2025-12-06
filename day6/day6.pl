use strict;
use warnings;
use List::Util 'sum';

my @lines = <STDIN>; # perl day6.pl < input.txt
chomp @lines;

# last line contains the operators
my $op_line = $lines[$#lines]; # I don't pop it because I need it for part 2.
my @ops = split(' ', $op_line);

################# PART ONE #####################
# '*' : start accumulating with 1 /// '+' : start with 0 
my @colres;
for my $i (0 .. $#ops) {
  $colres[$i] = $ops[$i] eq '*' ? 1 :  0;
}

# Process each data line
for my $line_idx (0 .. $#lines - 1) { # avoid the operators
  my $line = $lines[$line_idx];
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

################### PART TWO #####################
# Start from the bottom left: 
# 123 328  51 64 
#  45 64  387 23 
#   6 98  215 314
# *   +   *   +  
#
# For each CHAR column, (there are 15, 3 are empty) I change the current operator if needed, then ignore spaces and add $digit*10^($p++)
# The traversal will be in the order: *, SPC, SPC, 1, SPC, SPC, 4, 2, SPC, 6, 5, 3, SPC, SPC, SPC, SPC (empty column -> add the pending chunk)
# etc.

my $result_2 = 0;

my $current_op;
my $chunk_acc = 0; # represents a group of char columns with a common operator
for my $i (0 .. length($lines[0]) - 1) {
  my $bottom_char = substr($lines[$#lines],$i,1);
  if ($bottom_char eq '*') {
    # Commit previous chunk, initialize a new one
    $result_2 += $chunk_acc;
    $current_op = '*';
    $chunk_acc = 1;
  }
  elsif ($bottom_char eq '+') {
    $result_2 += $chunk_acc;
    $current_op = '+';
    $chunk_acc = 0;
  }
  my $power_of_10 = -1;
  my $col_num = 0; # number represented by the CHAR column
  for (my $j = $#lines - 1; $j >= 0; $j--) {
    my $digit = substr($lines[$j], $i, 1);
    next if $digit eq ' ';
    $power_of_10++;
    $col_num += $digit * 10**$power_of_10; # current CHAR column status 
  }
  if ($power_of_10 != -1) {
    if ($current_op eq '*') {
      $chunk_acc *= $col_num;
    }
    else { # ($current_op eq '+')
      $chunk_acc += $col_num;
    }
  } # else the column was empty! the chunk will be commited in the next iteration
}
# The last chunk
$result_2 += $chunk_acc;

my $total = sum(@colres);
print "$total\n";
print "$result_2\n";
