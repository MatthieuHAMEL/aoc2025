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

puts area

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
# path. Instead I apply the following reasoning:
# - From input.txt, there is an unique green path between P and P' described by the coordinates sequence.
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

# Whenever the green path goes "inside" the rectangle I mark the '!' edge coordinate. If it is never crossed
# again by the path, I know the rectangle is invalid. If P->P' is valid and P'->P is also valid, then the whole
# rectangle is valid.

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

def treshold(xstart, ystart, dir) # the threshold that, if crossed, invalidates the rectangle
  if dir == PathDir::LeftToRight or dir == PathDir::RightToLeft then
    ystart
  else # dir == PathDir::TopToBottom or dir == PathDir::BottomToTop
    xstart
  end
end

def traverses_rectangle(xr, yr, treshold, dir)
  if dir == PathDir::LeftToRight and yr > treshold then
    [xr+1, treshold]
  elsif dir == PathDir::RightToLeft and yr < treshold then
    [xr-1, treshold]
  elsif dir == PathDir::TopToBottom and xr < treshold then
    [treshold, yr+1]
  elsif dir == PathDir::BottomToTop and xr > treshold then
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

def process_line(coos, tresh, startIdx, endIdx, limit, dir)
  curi = startIdx
  dangling = nil
  loop do
    curi = (curi + 1) % coos.length
    xr, yr = coos[curi] # the next red cell on the path

    # If the rectangle was traversed by a path then the following is
    # the coordinates of the edge that MUST be crossed again for the rectangle to be valid
    unless dangling then
      dangling = traverses_rectangle(xr, yr, tresh, dir)
    end
    if dangling && dangling_crossed(xr, yr, tresh, dangling, dir) then
      dangling = nil
    end
    break if end_reached(xr, yr, dangling, curi, endIdx, limit, dir)
  end

  return [dangling, curi]
end

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
    # if x2 > x and y2 > x     or if

    # x, y = (11, 1) and x2, y2 = (2, 5)
    # 
    if (x2 > x and y2 > y) or (x2 < x and y2 < y) then
      dangling, cur_idx = process_line(coos, y, i, j, x2, (x2 > x) ? PathDir::LeftToRight : PathDir::RightToLeft)
      next if dangling # means we've reached P2 and the rectangle has been crossed
      dangling, cur_idx = process_line(coos, x2, cur_idx, j, nil, (y2 > y) ? PathDir::TopToBottom : PathDir::BottomToTop)
      next if dangling
      dangling, cur_idx = process_line(coos, y2, j, i, x, (x2 > x) ? PathDir::RightToLeft : PathDir::LeftToRight)
      next if dangling
      dangling, cur_idx = process_line(coos, x, cur_idx, i, nil, (y2 > y) ? PathDir::BottomToTop : PathDir::TopToBottom)
      next if dangling
    else
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
      dangling, cur_idx = process_line(coos, x, i, j, y2, (y2 > y) ? PathDir::TopToBottom : PathDir::BottomToTop)
      next if dangling
      dangling, cur_idx = process_line(coos, y2, cur_idx, j, nil, (x2 > x) ? PathDir::LeftToRight : PathDir::RightToLeft)
      next if dangling
      dangling, cur_idx = process_line(coos, x2, j, i, y, (y2 > y) ? PathDir::BottomToTop : PathDir::TopToBottom)
      next if dangling
      dangling, cur_idx = process_line(coos, y, cur_idx, i, nil, (x2 > x) ? PathDir::RightToLeft : PathDir::LeftToRight)
      next if dangling
    end
  

    puts "Area: #{ij_area}, for i, j  #{i}, #{j}"
    area = ij_area if ij_area > area
  end
end

puts area
