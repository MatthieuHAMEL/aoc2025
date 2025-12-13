use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::io;
use std::collections::HashSet;

#[derive(Copy, Clone)]
pub struct Point {
	x: u32,
	y: u32,
	z: u32
}

pub struct Pair {
	idx_a: usize, // the index of the point in the coordinates array
	idx_b: usize,
	dist: usize // the euclidean distance between coordinates[idx_a] and coordinate[idx_b]
}

// The vector is taken as &mut so that the method can be called repeatedly. (for part 2!)
// /!\ "frontier" between calls: when the caller asks for the N closest pairs starting from a distance of N,
// I'm careful and I don't add a pair that is already in the vector! (several pairs can have the same distance...)
// Limitation: the function cannot be called if there are less than num_closest pairs remaining.
pub fn find_n_closest(coordinates: &[Point], num_closest: usize, greater_than: usize, closest_pairs: &mut Vec<Pair>) {
	let initial_size = closest_pairs.len();
	let mut max_sq_dist = 0;
	for i in 0..coordinates.len() {
		'jloop: for j in (i+1)..coordinates.len() {
			let dist: usize =
				((coordinates[i].x as isize - coordinates[j].x as isize).pow(2)
				 + (coordinates[i].y as isize - coordinates[j].y as isize).pow(2)
				 + (coordinates[i].z as isize - coordinates[j].z as isize).pow(2)) as usize;
			
			if dist >= greater_than {
				// OPTIMIZATION: If I already added num_closest elts to closest_pairs, I don't even need to
				// add values with a distance that is higher that the highest of what I've added!...
				if closest_pairs.len() - initial_size >= num_closest && dist >= max_sq_dist {
					continue;
				}
				
				for i in ((closest_pairs.len() as isize - 1) as usize)..0 { // let's avoid pushing a pair that was already there
					// I assume closest_pairs[0..i] is sorted
					if closest_pairs[i].dist != dist { break; } // it wasn't there
					if closest_pairs[i].idx_a == i && closest_pairs[i].idx_b == j { // it was already there!
						continue 'jloop;
					}
				}
				
				closest_pairs.push(Pair{idx_a: i, idx_b: j, dist: dist});
			}
		}

		// We processed NB_LINES pairs and added the interesting ones to the vector. Sort it by ascending distances
		closest_pairs.sort_by(|elt1, elt2| elt1.dist.cmp(&elt2.dist)); // The first initial_size elements are already sorted.
		closest_pairs.truncate(initial_size + num_closest);
		max_sq_dist = closest_pairs.last().unwrap().dist;
	}
	assert!(closest_pairs.len() == initial_size + num_closest);
}

// pairs : slice of an array of (i, j, dist)
// Return the index of the iteration from which there is only one remaining circuit containing size_to_reach points (if that happens).
pub fn merge_pairs_in_circuits(pairs: &[Pair], circuits: &mut Vec<HashSet<usize>>, size_to_reach: usize) -> Option<usize> {
	let mut result: Option<usize> = None;
	
	for idx_pair in 0..pairs.len() {
		let pair = &pairs[idx_pair];
		let mut first_circuit_idx: Option<usize> = None;
		let mut second_circuit_idx: Option<usize> = None;
		// Is the 1st or the 2nd element of the pair already in a circuit?
		for i in 0..circuits.len() {
			if circuits[i].contains(&pair.idx_a) {
				first_circuit_idx = Some(i);
			}
			else if circuits[i].contains(&pair.idx_b) {
				// 'else' is intended:
				// secondcircuitidx is valued if (idx_a, idx_b) are found in two existing, different circuits
				// => those circuits will merge below!
				// By construction, an index never appears in two different circuits
				second_circuit_idx = Some(i);
			}
		}

		// First case: "pair" gets its own circuit (it can't connect with any other pair)
		if first_circuit_idx.is_none() && second_circuit_idx.is_none() {
			let mut new_circuit = HashSet::new();
			new_circuit.insert(pair.idx_a);
			new_circuit.insert(pair.idx_b);
			circuits.push(new_circuit);
		}
		// Second case: both parts of "pair" were in different circuits => merge them
		else if first_circuit_idx.is_some() && second_circuit_idx.is_some() {
			let idx1 = first_circuit_idx.unwrap();
			let idx2 = second_circuit_idx.unwrap();
			assert!(idx1 != idx2); // by construction
			
			// Remove the higher index to avoid shifting the element I keep.
			let (keep, remove) = if idx1 < idx2 { (idx1, idx2) } else { (idx2, idx1) };
			let tmp = circuits[remove].clone();
			circuits[keep].extend(tmp);
			circuits.remove(remove);
		}
		else if let Some(idx1) = first_circuit_idx {
			circuits[idx1].insert(pair.idx_a);
			circuits[idx1].insert(pair.idx_b);
		}
		else if let Some(idx2) = second_circuit_idx {
			circuits[idx2].insert(pair.idx_a);
			circuits[idx2].insert(pair.idx_b);
		}
		else { assert!(false); }

		if circuits.len() == 1 && size_to_reach == circuits[0].len() && result.is_none() {
			result = Some(idx_pair);
		}
	}
	result
}

fn main() -> io::Result<()> {
	let file = File::open("input.txt")?;
	let mut reader = BufReader::new(file);

	// Static array since I know there are 1000 lines in the file
	const NB_LINES: usize = 1000;
	let mut coordinates = [Point{x: 0, y: 0, z: 0}; NB_LINES];
	
	for i in 0..NB_LINES {
		let mut buf = String::new();
		let _ = reader.read_line(&mut buf);
		let mut parts = buf.trim().split(',').map(|s| s.parse::<u32>().unwrap());
		
		coordinates[i].x = parts.next().unwrap();
		coordinates[i].y = parts.next().unwrap();
		coordinates[i].z = parts.next().unwrap();
	}

	// Part 1: get the 1000 closest pairs, merge them in the circuits
	const PART_1_NB_CLOSEST: usize = 1000;
	let mut closest_pairs = Vec::with_capacity(PART_1_NB_CLOSEST);
	find_n_closest(&coordinates, PART_1_NB_CLOSEST, 0, &mut closest_pairs);
	
	let mut circuits: Vec<HashSet<usize>> = Vec::new(); // One circuit is the vector of indexes of a coordinate
	merge_pairs_in_circuits(&closest_pairs[..], &mut circuits, /*not used here*/0);

	// ... then get the 3 largest circuits and multiply their sizes
	circuits.sort_by(|a, b| b.len().cmp(&a.len()));
	let result = circuits[0].len() * circuits[1].len() * circuits[2].len();
	println!("{:?}", result);

	////////////////////////////////////////////////////////////
	// Part 2: I call repeatedly find_n_closest and merge_pairs_in_circuits on arbitrarily-sized batches of pairs to find
	// When there's only one circuit containing all points, merge_pairs_in_circuits returns the slice-wide index of the first
	// pair that allowed that event to happen.
	let mut n = 0;
	let index_merge: usize;
	const BATCH_SIZE: usize = 2000;
	loop {
		find_n_closest(&coordinates, BATCH_SIZE, /*starting from dist*/closest_pairs.last().unwrap().dist, &mut closest_pairs);
		if let Some(idx) = merge_pairs_in_circuits(&closest_pairs[PART_1_NB_CLOSEST + n*BATCH_SIZE..], &mut circuits, NB_LINES) {
			if circuits[0].len() == NB_LINES { // else there is 1 circuit but it doesn't contain the whole network!
				index_merge = PART_1_NB_CLOSEST + n*BATCH_SIZE + idx;
				break;
			}
		}
		n += 1;
	}

	let result_2 : usize = coordinates[closest_pairs[index_merge].idx_a].x as usize * coordinates[closest_pairs[index_merge].idx_b].x as usize;
	println!("{}", result_2);
	Ok(())
}
