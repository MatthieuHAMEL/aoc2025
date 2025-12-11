use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::io;

fn main() -> io::Result<()> {
	const NB_LINES: usize = 1000;
	let file = File::open("input.txt")?;
  let mut reader = BufReader::new(file);

	// Static array since I know there are 1000 lines in the file
	let mut coordinates = [(0u32, 0u32, 0u32); NB_LINES];
	
	for i in 0..NB_LINES {
		let mut buf = String::new();
		let _ = reader.read_line(&mut buf);
		let mut parts= buf.trim().split(',').map(|s| s.parse::<u32>().unwrap());
		
    let x = parts.next().unwrap();
    let y = parts.next().unwrap();
    let z = parts.next().unwrap();
    coordinates[i] = (x, y, z);
  }

	let mut closest_pairs = Vec::with_capacity(2*NB_LINES);
	let mut max_sq_dist = 0usize; // above this max (once initialized)
	for i in 0..NB_LINES {
		for j in 0..NB_LINES {
			let dist: usize =
				  ((coordinates[i].0 as isize - coordinates[j].0 as isize).pow(2)
				+ (coordinates[i].1 as isize - coordinates[j].1 as isize).pow(2)
				+ (coordinates[i].2 as isize - coordinates[j].2 as isize).pow(2)) as usize;
			if i > 0 && dist > max_sq_dist {
				continue; // No need to push it, it's too high! (that logic doesn't apply to the first loop turn i.e. when there are <NB_LINES elements)
			}
			closest_pairs.push((i, j, dist));
		}

		// We processed NB_LINES pairs and added the interesting ones to the vector. Sort it by ascending distances
		closest_pairs.sort_by(|elt1, elt2| elt1.2.cmp(&elt2.2));
		closest_pairs.truncate(NB_LINES);
		max_sq_dist = closest_pairs[NB_LINES-1].2;
	}

	assert!(closest_pairs.len() == NB_LINES);
	


  Ok(())
}
