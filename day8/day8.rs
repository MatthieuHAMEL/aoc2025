use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;
use std::io;

fn main() -> io::Result<()> {
	println!("hello world");

	// The assignment is phrased in such a way that one might think
	// that the 1000 pairs of coordinates have to be found in order (the closest pair first, etc)
	// This is not the case - a single quadratic pass is enough (maybe there is better?)
	
	let file = File::open("input.txt")?;
  let mut reader = BufReader::new(file);

	// Static array since I know there are 1000 lines in the file
	let mut coordinates = [(0u32, 0u32, 0u32); 1000];
	
	for i in 0..1000 {
		let mut buf = String::new();
		let _ = reader.read_line(&mut buf);
		let mut parts= buf.trim().split(',').map(|s| s.parse::<u32>().unwrap());
		
    let x = parts.next().unwrap();
    let y = parts.next().unwrap();
    let z = parts.next().unwrap();
    coordinates[i] = (x, y, z);
  }


  Ok(())
}
