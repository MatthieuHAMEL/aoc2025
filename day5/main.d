import std.stdio;
import std.range;
import std.algorithm;
import std.conv;

bool isInRanges(ulong ingredient_id, const(ulong[2][]) ranges) {
  foreach (range; ranges) {
    if (range[0] <= ingredient_id && ingredient_id <= range[1]) {
      return true;
    }
  }
  return false;
}

// For part 2
// The ranges overlap. I don't want to build a map (int => bool) "has my int been counted yet"?
// given the data, indeed, the total number of integers in those ranges is huge, while there is
// a reasonably low amount of ranges.
// So the best solution I see is to build another ranges array without any overlapping
// Then the solution becomes as simple as adding up every range size.
ulong countFreshIngredients(const(ulong[2][]) ranges)
{
  if (ranges.length == 0)
    return 0;
  
  // Sort by lower bound value:
  auto sorted = ranges.dup;
  sort!((a, b) => a[0] < b[0])(sorted);

  // The idea is : start with the first range's lowest bound, which is the overall lowest number
  // I can encounter thanks to the sort. Then absorb the following ranges if they overlap with mine.
  // When I encounter a range that doesn't overlap I know that I'm done with my current growing range.
  ulong result;
  ulong[2] cur = sorted[0]; // current merged interval
  foreach (i; 1 .. sorted.length) {
    auto rg = sorted[i];
    if (rg[0] <= cur[1] + 1) {
      if (rg[1] > cur[1]) { // Extend current range if necessary
        cur[1] = rg[1];
      }
    } else { // Disjoint: close current and start new. 
      result += cur[1] - cur[0] + 1; // The sort gives the guarantee that nothing will intersect with [cur0, cur1]
      cur = rg;
    }
  }
  // The last one:
  result += cur[1] - cur[0] + 1;
  return result;
}

void main()
{
  auto file = File("input.txt");
  auto lines = file.byLine();

  ////////////////// PART ONE //////////////////////
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

  ////////////////// PART TWO //////////////////////
  ulong result_part_2 = countFreshIngredients(ranges);
  writefln("%u", result_part_2);
}
