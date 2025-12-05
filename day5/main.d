import std.stdio;
import std.range;
import std.algorithm;
import std.conv;

bool isInRanges(ulong ingredient_id, ulong[2][] ranges) {
  foreach (range; ranges) {
    if (range[0] <= ingredient_id && ingredient_id <= range[1]) {
      return true;
    }
  }
  return false;
}

void main()
{
  auto file = File("input.txt");
  auto lines = file.byLine();

  // 1st loop : parse the "fresh ingredient IDs" ranges
  ulong[2][] ranges; // "dynamic array of N arrays of 2". Yes, it's the opposite than in C (?!)
  while (true) {
    auto line = lines.front;
    lines.popFront();
    if (line.empty) { // We're done with ranges
      break;
    }
    
    auto parts = line.split("-");
    ulong[2] r = [to!ulong(parts[0]), to!ulong(parts[1])];
    ranges ~= r;
  }

  // 2nd loop on the rest of the file: count the ingredient IDs that are fresh (== in a range)
  ulong result = 0;
  foreach (ref line; lines) {
    if (isInRanges(to!ulong(line), ranges)) {
      result++;
    }
  }

  writefln("%u", result);
}
