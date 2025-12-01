#!/usr/bin/raku
unit sub MAIN(IO() $inputfile where *.f = 'input.txt');

my $pos = 50; # Initial position
my $result = 0; # Number of time the dial points at 0

for $inputfile.IO.lines -> $line {
    my $steps = $line.substr(1).Int;
    $pos = ($pos + ($line.substr(0, 1) eq 'L' ?? -$steps !! $steps)) % 100;
    $result++ if $pos == 0;
}

say $result;
