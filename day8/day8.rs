use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::io;

fn main() -> io::Result<()> {
 	const NB_LINES: usize =1000;
	let file = File::open("input.txt")?;
	let mut reader = BufReader::new(file);

	// Static array since I know there are 1000 lines in the file
	let mut coordinates = [(0u32, 0u32, 0u32); NB_LINES];
	
	for i in 0..NB_LINES {
		let mut buf = String::new();
		let _ = reader.read_line(&mut buf);
		println!("{}", i);
		let mut parts= buf.trim().split(',').map(|s| s.parse::<u32>().unwrap());
		
		let x = parts.next().unwrap();
		let y = parts.next().unwrap();
		let z = parts.next().unwrap();
		coordinates[i] = (x, y, z);
	}

	let mut closest_pairs = Vec::with_capacity(2*NB_LINES);
	let mut max_sq_dist = 0usize; // above this max (once initialized)
	for i in 0..NB_LINES {
		for j in (i+1)..NB_LINES {
			let dist: usize =
				((coordinates[i].0 as isize - coordinates[j].0 as isize).pow(2)
				 + (coordinates[i].1 as isize - coordinates[j].1 as isize).pow(2)
				 + (coordinates[i].2 as isize - coordinates[j].2 as isize).pow(2)) as usize;

			// NB: once there are NB_LINES elements in closest_pairs I could compare dist to a max to avoid pushing everything
			closest_pairs.push((i, j, dist));
		}

		// We processed NB_LINES pairs and added the interesting ones to the vector. Sort it by ascending distances
		closest_pairs.sort_by(|elt1, elt2| elt1.2.cmp(&elt2.2));
		closest_pairs.truncate(NB_LINES);
	}
	println!("clo pairs {:?}", closest_pairs);
	assert!(closest_pairs.len() == NB_LINES);
	
	let mut circuits: Vec<Vec<usize>> = Vec::new(); // One circuit is the vector of indexes of a coordinate
	for pair in closest_pairs.iter() {
		let mut firstCircuitIdx: Option<usize> = None;
		let mut secondCircuitIdx: Option<usize> = None;
		// Is the 1st or the 2nd element of the pair already in a circuit?
		for i in 0..circuits.len() {
			if circuits[i].contains(&pair.0) {
				firstCircuitIdx = Some(i);
			}
			else if circuits[i].contains(&pair.1) {
				// the "else" is intended; if the following remains None I just add pair.1 in the 1st circuit
				secondCircuitIdx = Some(i);
			}
		}

		// First case: "pair" gets its own circuit (it can't connect with any other pair)
		if firstCircuitIdx.is_none() && secondCircuitIdx.is_none() {
			circuits.push(vec![pair.0, pair.1]);
		}
		// Second case: both parts of "pair" were in different circuits => merge them
		else if firstCircuitIdx.is_some() && secondCircuitIdx.is_some() {
			let idx1 = firstCircuitIdx.unwrap();//wtf compiler!!!
			let idx2 = secondCircuitIdx.unwrap();
			assert!(idx1 != idx2); // by construction
			
			// Remove the higher index to avoid shifting the element I keep.
			let (keep, remove) = if idx1 < idx2 { (idx1, idx2) } else { (idx2, idx1) };
			let tmp = circuits[remove].clone();
			circuits[keep].extend(tmp);
			circuits.remove(remove);
		}
		else if let Some(idx1) = firstCircuitIdx {
			if !circuits[idx1].contains(&pair.0) { // use a set (TODO)
				circuits[idx1].push(pair.0);
			}
			if !circuits[idx1].contains(&pair.1) {
				circuits[idx1].push(pair.1);
			}
		}
		else if let Some(idx2) = secondCircuitIdx {
			if !circuits[idx2].contains(&pair.0) {
				circuits[idx2].push(pair.0);
			}
			if !circuits[idx2].contains(&pair.1) {
				circuits[idx2].push(pair.1);
			}
		}
		else {
			assert!(false);
		}
	}

	// get the 3 largest circuits
	circuits.sort_by(|a, b| b.len().cmp(&a.len()));
	println!("{:?}", circuits);

	let result = circuits[0].len() * circuits[1].len() * circuits[2].len();
	println!("{:?}", result);
  Ok(())
}
