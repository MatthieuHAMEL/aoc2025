#!/usr/bin/raku
unit sub MAIN(IO() $inputfile where *.f = 'input.txt');

my $pos = 50; # Initial position
my ($result_1, $result_2) = 0, 0; # Number of time the dial points at 0

for $inputfile.IO.lines -> $line {
    my $steps = $line.substr(1).Int;
    my $pos_unbounded = ($pos + ($line.substr(0, 1) eq 'L' ?? -$steps !! $steps));
    
    # There must be a more elegant way to write it!
    my $nb_0_crossings;
    if ($pos_unbounded > 0) {
        $nb_0_crossings = abs($pos_unbounded div 100);
    }
    else {
        $nb_0_crossings-- if ($pos == 0); # special case if we started from 0 to end in the negative
        $nb_0_crossings += abs(($pos_unbounded - 1) div 100);
    }

    $result_2 += $nb_0_crossings;
    
    $pos = $pos_unbounded mod 100;
    # old method:
    $result_1++ if $pos == 0;
}

say $result_1;
say $result_2;
