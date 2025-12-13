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
