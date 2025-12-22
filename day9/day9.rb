coos = Array.new
File.open('input.txt').each do |line|
  coos.push(line.split(',').map(&:to_i))
end

# Part 1: bruteforce...
n = coos.length
area = 0
for i in 0...n
  for j in i+1...n # note that if j == i+1, the rectangle is a flat line
    ij_area = ((coos[i][0] - coos[j][0]).abs + 1) * ((coos[i][1] - coos[j][1]).abs + 1)
    area = ij_area if ij_area > area
  end
end

puts "---) Part 1 solution: #{area}"

# require "byebug"
# byebug

# Part 2: I could build the whole structure and mark every green and red cell, and
# get the result with a simple loop. But the grid is 100k x 100k, the solution
# wouldn't be elegant, and there is a RAM shortage.

# Consider opposite rectangle corners in P(x, y) and P2(x2, y2) :
#         x      x2
#       ..............
# y ->  ..#...........   P(x, y)
#       ..............
# y2->  .........#....   P2(x2, y2)
#       ..............
# What makes this rectangle admissible or not according to the rules of assignment 2?
# If every edge cell is either red or green, then the whole interior of the rectangle
# is covered by red or green cells.
# -> I just need to prove that (x, y), (x+1, y) ... until (x2, y) are red or green,
# same for (x2, y), (x2, y+1), ... (x2, y2), etc for the 4 edges
# It is not easy to prove that one given edge cell is red or green without building the
# whole structure: that cell could be green because it is enclosed in another bigger
# path.
# Instead I apply the following reasoning:
# - From input.txt, there is an unique green path of edges ("the snake") between P and P'.
# From P I can iterate on that path: it's a sequence of straight lines to red cells, P' being the last one.
# What I need to know is whether that green path correctly "encloses" the segments
# P -> (x2, y), (x2, y) -> P', P' -> (x, y2) and (x, y2) -> P
# That is whether the green path traverses the interior of the rectangle or not. If it does and if
# edge cells are missed, then the rectangle is invalid.

#         x  #X# x2
#       .....X.X......
# y ->  ..#XXX.XXXX#..
#       ...........X..  # OK: this path never goes in the rectangle interior
# y2->  .........#X#..
#       ..............

#         x   !    x2
#       ..............
# y ->  ..#XX#.#XXX#..
#       .....X.X...X..  # Wrong: this path goes into the rectangle and the edge whose x-coordinate is marked ! is missed
# y2->  .....#X#.#X#..
#       ..............

#         x   !    x2
#       ..............
# y ->  ..#XX###XXX#..
#       .....XX....X..  # OK: the path goes into the rectangle but no edge cell is missed after all.
# y2->  .....##..#X#..
#       ..............

# So the following algorithm just tries to play "snake". Whenever it goes "inside" the rectangle, I mark the next "missed"
# cell as "dangling". If it is never crossed again, it invalidates the rectangle. 
# If there is no dangling cell P->P' nor on P'->P, then the whole rectangle is valid.

module PathDir
  RightToLeft = 1
  LeftToRight = 2
  TopToBottom = 3
  BottomToTop = 4
end

def end_reached(xr, yr, dangling, curIdx, endIdx, limit, dir)
  if curIdx == endIdx then # it's over anyway.
    return true
  end
  if !limit then # if there is no given limit it means we must continue until endIdx
    return false
  end
  if dangling then # if there is a limit and if there is a cell to fill that we didn't see, it's not done
    return false
  end
  
  if dir == PathDir::LeftToRight then
    return xr >= limit
  elsif dir == PathDir::RightToLeft then
    return xr <= limit
  elsif dir == PathDir::TopToBottom then
    return yr >= limit
  else # dir == PathDir::BottomToTop then
    return yr <= limit
  end
end

# Return the next coordinate of the edge that is "dangling", i.e.
# it may not be reached by the path since that path traverses the rectangle.
def traverses_rectangle(xr, yr, treshold, dir, startval)
  if dir == PathDir::LeftToRight and xr >= startval && yr > treshold then # if x is not even in the rectangle it doesn't count!
    [xr+1, treshold]
  elsif dir == PathDir::RightToLeft and xr <= startval && yr < treshold then
    [xr-1, treshold]
  elsif dir == PathDir::TopToBottom and yr >= startval && xr < treshold then
    [treshold, yr+1]
  elsif dir == PathDir::BottomToTop and yr <= startval && xr > treshold then
    [treshold, yr-1]
  else
    nil
  end
end

def dangling_crossed(xr, yr, treshold, dangling, dir)
  dangling && (
    (dir == PathDir::LeftToRight && yr <= treshold && xr == dangling[1]) ||
    (dir == PathDir::RightToLeft && yr >= treshold && xr == dangling[1]) ||
    (dir == PathDir::TopToBottom && xr >= treshold && yr == dangling[0]) ||
    (dir == PathDir::BottomToTop && xr <= treshold && yr == dangling[0]))
end

# coos: the content of input.txt
# startIdx : the index (of coordinates) from which I start looping until I reach the end of the line
# endIdx : the index of the coordinates of the other angle. This algorithm may stop before it is reached
#   (when I get the end of the line without a dangling cell)
# startval: relatively to the direction axis: the x or y coordinate of the beginning of the rectangle line
# limit: .....................................the x or y coordinate that we want to reach to complete the line
#   /!\ limit can be none if the target is a red angle.
# dir : cf PathDir
def process_line(coos, tresh, startIdx, endIdx, startval, limit, dir)
  curi = startIdx
  dangling = nil
  xrprev, yrprev = coos[curi]
  loop do
    curi = (curi + 1) % coos.length
    xr, yr = coos[curi] # the next red cell on the path

    # If the rectangle was traversed by a path then the following is
    # the coordinates of the edge that MUST be crossed again for the rectangle to be valid
    unless dangling then
      dangling = traverses_rectangle(xr, yr, tresh, dir, startval)
    end
    if dangling && dangling_crossed(xr, yr, tresh, dangling, dir) then
      dangling = nil
    end
    break if end_reached(xr, yr, dangling, curi, endIdx, limit, dir)
  end

  return [dangling, curi]
end

start = Time.now

area = 0
for i in 0...n
  for j in i+1...n
    x, y = coos[i]
    x2, y2 = coos[j]
    ij_area = ((x - x2).abs + 1) * ((y - y2).abs + 1)

    # Optimization: don't even check the rectangle validity if its area is smaller than the best area so far!
    next if ij_area < area

    if j == i+1 then # the rectangle is a straight line -> it is valid!
      area = ij_area if ij_area > area
      next
    end
    
    # Non-trivial rectangles:
    #      x      x2  
    #    ..............
    # y  ..#...........   P(x, y)
    #    ..............
    # y2 .........#....   P2(x2, y2)
    #    ..............
    if (x2 > x and y2 > y) or (x2 < x and y2 < y) then # first configuration
      dangling, cur_idx = process_line(coos, y, i, j, x, x2, (x2 > x) ? PathDir::LeftToRight : PathDir::RightToLeft)
      next if dangling # means we've reached P2 and the rectangle has been crossed
      dangling, cur_idx = process_line(coos, x2, cur_idx, j, y, nil, (y2 > y) ? PathDir::TopToBottom : PathDir::BottomToTop)
      next if dangling
      dangling, cur_idx = process_line(coos, y2, j, i, x2, x, (x2 > x) ? PathDir::RightToLeft : PathDir::LeftToRight)
      next if dangling
      dangling, cur_idx = process_line(coos, x, cur_idx, i, y2, nil, (y2 > y) ? PathDir::BottomToTop : PathDir::TopToBottom)
      next if dangling
    else # 2nd configuration:
      #      x2      x                     
      #    ..............
      # y  .........#....   P(x, y)
      #    ..............
      # y2 ..#...........   P2(x2, y2)
      #    ..............
      # ... or :
      #      x      x2  
      #    ..............
      # y2 .........#....   P(x, y)
      #    ..............
      # y  ..#...........   P2(x2, y2)
      #    ..............
      dangling, cur_idx = process_line(coos, x, i, j, y, y2, (y2 > y) ? PathDir::TopToBottom : PathDir::BottomToTop)
      next if dangling
      dangling, cur_idx = process_line(coos, y2, cur_idx, j, x, nil, (x2 > x) ? PathDir::LeftToRight : PathDir::RightToLeft)
      next if dangling
      dangling, cur_idx = process_line(coos, x2, j, i, y2, y, (y2 > y) ? PathDir::BottomToTop : PathDir::TopToBottom)
      next if dangling
      dangling, cur_idx = process_line(coos, y, cur_idx, i, x2, nil, (x2 > x) ? PathDir::RightToLeft : PathDir::LeftToRight)
      next if dangling
    end
    area = ij_area if ij_area > area
  end
end

finish = Time.now

puts "---) Part 2 result ('snake solution') : #{area} computed in #{finish-start} s"


# 3rd approach, compressing the grid
# The idea came later and it is probably saner than "the snake" above (though the snake gives a correct result)
# the coordinates represent points in a 100k x 100k grid but there are only 500 coordinates. Their values
# are important in order to compute the right distances & areas. But only their order and relative values
# matter when it comes to checking the validity of a rectangle. This means I can "compress" the whole grid
# and compute the result on a tiny ~ 250 x 250 grid.

# Given the problem data, this solution (unlike the snake) has a memory footprint,
# but it greatly improves the time complexity!!!

puts "---> Part 2 compressed approach BEGIN"

start = Time.now

# Just sort the coordinates. The lowest x becomes 0, etc.
xs = coos.map(&:first).uniq.sort
ys = coos.map(&:last).uniq.sort

x_to_i = {}
xs.each_with_index { |x, i| x_to_i[x] = i }

y_to_i = {}
ys.each_with_index { |y, i| y_to_i[y] = i }

width  = xs.length
height = ys.length
occupancy = Array.new(height) { Array.new(width, false) } # 248 x 247 in my case (there were a few duplicates)

# grid mapping: grid[y_idx][x_idx] = [x, y] or nil
# This was used only for debugging.
grid = Array.new(height) { Array.new(width, nil) }

# This time I really build the grid, but the compressed one!
module CellContent
  Red = 1
  Green = 2
  Interior = 3 # Also green but it's easier to debug
end

for i in 0...n
  x, y = coos[i]
  xi, yi = x_to_i[x], y_to_i[y]

  occupancy[yi][xi] = CellContent::Red
  grid[yi][xi] = [x, y] # mapping back to original coords (for debugging)

  # Mark the edges
  x2, y2 = coos[(i+1) % n]
  x2i, y2i = x_to_i[x2], y_to_i[y2]
  if xi == x2i then
    bmin, bmax = [yi, y2i].minmax
    for yti in bmin+1...bmax
      occupancy[yti][xi] = CellContent::Green
    end
  elsif yi == y2i then
    bmin, bmax = [xi, x2i].minmax
    for xti in bmin+1...bmax
      occupancy[yi][xti] = CellContent::Green
    end    
  end
end

# Now mark the interior:
# Naive filling algorithm. First I locate an obvious interior cell:
ifl, jfl, done = 0, 0, false
for i in 0...height
  break if done
  for j in 0...width
    next if !occupancy[i][j]
    # else I just hit a wall:
    
    if j+1 < width && !occupancy[i][j+1] # I made it past the wall
      ifl, jfl = i, j+1
      done = true
      break
    else break # Try on another line (I want to cross a thin wall only, to be sure that the other side is the interior)
    end
  end
end

# Then flood fill
queue = [[ifl, jfl]]
while !queue.empty? do
  i, j = queue.pop
  
  # Mark the cell as interior and collect neighbors
  occupancy[i][j] = CellContent::Interior
  if i+1 < height && !occupancy[i+1][j] then queue.append([i+1, j]) end
  if j+1 < width && !occupancy[i][j+1] then queue.append([i, j+1]) end
  if i-1 >= 0 && !occupancy[i-1][j] then queue.append([i-1, j]) end
  if j-1 >= 0 && !occupancy[i][j-1] then queue.append([i, j-1]) end
end

# Write ASCII compressed grid, this was for debugging purposes
# File.open("compressed_grid.txt", "w") do |f|
#   occupancy.each_with_index do |row, i|
#     f.print row.map { |cell|
#       if cell == 1 then "#"
#       elsif cell == 2 then "X"
#       elsif cell == 3 then "o"
#       else "."
#       end
#     }.join

#     # at the end of the line write in order the real coordinates...
#     row.each_with_index { |cell, j|
#       if cell == 1 then
#         f.print grid[i][j], " "
#       end
#     }
#     f.print "\n"
#   end
# end

# this helped to debug:
# grid[yi][xi] -> [original_x, original_y] or nil
# puts grid[0][0].inspect

puts "\t---> (alternative approach) Read #{coos.length} points"
puts "\t---> (alternative approach) Compressed to #{width}x#{height} grid"

# now compute the result on the compressed grid
def check_green(occupancy, xi, yi, x2i, y2i)
  xmin, xmax = [xi, x2i].minmax
  ymin, ymax = [yi, y2i].minmax

  (xmin..xmax).each do |x|
    return false unless occupancy[ymin][x] && occupancy[ymax][x]
  end
  
  (ymin..ymax).each do |y|
    return false unless occupancy[y][xmin] && occupancy[y][xmax]
  end
  
  true
end

old_area = area
area = 0
for i in 0...n
  for j in i+1...n
    x, y = coos[i]
    x2, y2 = coos[j]
    ij_area = ((x - x2).abs + 1) * ((y - y2).abs + 1)

    next if ij_area < area
    
    if j != i+1 then # for non-trivial rectangles (j == i+1 being a line), check validity
      xi, yi = x_to_i[x], y_to_i[y]
      x2i, y2i = x_to_i[x2], y_to_i[y2]
      next unless check_green(occupancy, xi, yi, x2i, y2i)
    end

    if ij_area > area then
      puts "\t---> (alternative approach) got area #{ij_area} for #{i}, #{j}"
      area = ij_area
    end
  end
end

finish = Time.now

puts "---) Part 2 alternative approach result is #{area} computed in #{finish-start} s"

raise "Booooh" if old_area != area # this doesn't raise
