coos = Array.new
File.open('input.txt').each do |line|
  coos.push(line.split(',').map(&:to_i))
end

# Part 1: bruteforce...
n = coos.length
area = 0
for i in 0...n
  for j in i+1...n
    ij_area = ((coos[i][0] - coos[j][0]).abs + 1) * ((coos[i][1] - coos[j][1]).abs + 1)
    area = ij_area if ij_area > area
  end
end

puts area

# Part 2: I could build the whole structure and mark every green and red cell, and
# get the result with a simple loop. But the grid is 100k x 100k, the solution
# wouldn't be elegant, and there is a RAM shortage.

# Consider opposite rectangle corners in P(x, y) and P'(x', y') :
#         y      y'
#       ..............
# x ->  ..#...........   P(x, y)
#       ..............
# x'->  .........#....   P'(x', y')
#       ..............
# What makes this rectangle admissible or not according to the rules of assignment 2?
# If every edge cell is either red or green, then the whole interior of the rectangle
# is covered by red or green cells.
# -> I just need to prove that (x, y+1), (x, y+2) ... until (x, y') are red or green,
# same for (x, y'), (x+1, y'), ... (x', y'), etc.
# It is not easy to prove that one given edge cell is red or green without building the
# whole structure, because that cell could be green because it is enclosed in another bigger
# path. Instead I apply the following reasoning:
# - From the given input.txt, there is an unique green path between P and P'.
# From P I can iterate on it: it's a sequence of straight lines to red cells, P' being the last one.
# What I need to know is whether that green path correctly "encloses" the segments P -> (x, y') and (x, y') -> P'.
# That is whether the green path goes into the interior of the rectangle or not. If it does and if
# edge cells are missed, then the rectangle is invalid.

#         y  #x# y'
#       .....x.x......
# x ->  ..#xxx.xxxx#..
#       ...........x..  # OK: this path never goes in the rectangle
# x'->  .........#x#..
#       ..............

#         y   !    y'
#       ..............
# x ->  ..#xx#.#xxx#..
#       .....x.x...x..  # Wrong: this path goes into the rectangle and the edge cell marked ! is missed
# x'->  .....#x#.#x#..
#       ..............

#         y   !    y'
#       ..............
# x ->  ..#xx###xxx#..
#       .....xx....x..  # OK: the path goes into the rectangle but no edge cell is missed after all.
# x'->  .....##..#x#..
#       ..............

# Whenever the green path goes "inside" the rectangle I mark the '!' edge coordinate. If it is never crossed
# again by the path, I know the rectangle is invalid. If P->P' is valid and P'->P is also valid, then the whole
# rectangle is valid.

