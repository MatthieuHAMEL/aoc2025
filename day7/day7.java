import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.ArrayList;
import java.util.Stack;

// For part 1
class BeamCoordinate {
  public BeamCoordinate(int i, int j) {
    this.i = i;
    this.j = j;
  }
  public int i;
  public int j;
}

// For part 2
class BeamData {
  public BeamData(int iIdx, long iNbPaths) {
    index = iIdx;
    nb_paths = iNbPaths;
  }
  public int index; // relatively to the line it is on...
  public long nb_paths; // Number of possible paths from the beginning, to that beam
}

class day7 {
  public static void main(String[] args) throws FileNotFoundException {
    File file = new File("input.txt");
    Scanner scanner = new Scanner(file);

    // Get the number of lines to allocate the right amount of lines
    int line_count = 0;
    while (scanner.hasNextLine()) {
      line_count++;
      scanner.nextLine();
    }
    scanner.close(); // Of course Java is not able to reset a scanner **for real** !  ....

    // Get the char matrix from the file
    var data_in = new char[line_count][]; // Strings are immutable and I want to mark visited cells...
    scanner = new Scanner(file);
    {
      int i = 0;
      while (scanner.hasNextLine()) {
        data_in[i++] = scanner.nextLine().toCharArray();
      }
    }
    
    int indexOfStart = 0;
    while (data_in[0][indexOfStart] != 'S') { // There is no indexOf() on java arrays ...
      indexOfStart++;
    }
    var nodes = new Stack<BeamCoordinate>();
    nodes.push(new BeamCoordinate(0, indexOfStart));
    int nb_split = 0;
    while (!nodes.isEmpty()) {
      var node = nodes.pop();
      
      // Look at the cell below the current index
      int i_next = node.i + 1; // the next line index
      if (i_next == line_count) { // Last line reached => nothing to do
        continue; 
      }
  
      int j = node.j;
      if (data_in[i_next][j] == '.') {
        // The tachyon doesn't split. Push the below cell in the stack
        nodes.push(new BeamCoordinate(i_next, j)); // same horizontal index!
        data_in[i_next][j] = '|';
      }
      else if (data_in[i_next][j] == '|') { // already visited
        continue;
      }
      else { // '^' : split the tachyon left & right
        nb_split++;
        if (j - 1 >= 0 && data_in[i_next][j-1] == '.') {
          nodes.push(new BeamCoordinate(i_next, j-1));
          data_in[i_next][j-1] = '|';
        }
        if (j + 1 < data_in[i_next].length && data_in[i_next][j+1] == '.') {
          nodes.push(new BeamCoordinate(i_next, j+1));
          data_in[i_next][j+1] = '|';
        }
      }
    }
    
    System.out.printf("%d\n", nb_split);

    // Part 2 ////////////////////////////////////////////////////
    // Take the "fully splitted" grid from the assignment example:
    // .......S.......
    // .......|.......  
    // ......|^|......  
    // ......|.|......  
    // .....|^|^|.....  
    // .....|.|.|.....  
    // ....|^|^|^|....  
    // ....|.|.|.|....  
    // ...|^|^|||^|...  
    // ...|.|.|||.|...
    // ..|^|^|||^|^|..  
    // ..|.|.|||.|.|..
    // .|^|||^||.||^|.
    // .|.|||.||.||.|.
    // |^|^|^|^|^|||^|
    // |.|.|.|.|.|||.|
    // I write the "possible" coordinates for each line as a list of lists of indexes:
    // [7], [6, 8], [6, 8], [5, 7, 9], [5, 7, 9], [4, 6, 8, 10], ...]
    // For each Ki_j (beam at line i, index j), how many ways are there to reach it?
    // I build the corresponding array 
    // [7], [6, 8], [6, 8], [5, 7, 9], [5, 7, 9], [4, 6, 8, 10], ...]
    // [1], [1, 1], [1, 1], [1, 2, 1], [1, 2, 1], [1, 3, 3, 1], ...]
    // The solution is the sum of the last line.
    
    // Let's compute that list of lists first, starting from the result of part 1.
    // I don't use an int[][] because I don't know the size of each line
    var every_beam = new ArrayList<ArrayList<BeamData>>(line_count);
    for (int iHateJava = 0; iHateJava < line_count; iHateJava++) { every_beam.add(new ArrayList<BeamData>()); }

    every_beam.get(0).add(new BeamData(indexOfStart, 1)); // index of 'S'; there is 1 way to go to it
    for (int i = 1; i < line_count; i++) {
      // every_beam[i] == the list of indexes of every '|' at line i
      for (int index = 0; index < data_in[i].length; index++) {
        if (data_in[i][index] == '|') {
          every_beam.get(i).add(new BeamData(index, 0)); // for now there is 0 way to go to that new beam
        }
      }

      // Now let's compute the number of possible paths with respect to the step i-1
      for (BeamData prev: every_beam.get(i-1)) { // A beam from the previous line
        for (BeamData cur: every_beam.get(i)) {  // A beam from the current line
          // If is possible to go from prev to cur (directly or because of a split)
          if (prev.index == cur.index || (Math.abs(prev.index - cur.index) == 1 && data_in[i][prev.index] == '^')) {
            // The "prev.nb_paths" ways to go to prev are propagated to cur
            cur.nb_paths += prev.nb_paths;
          }
        }
      }      
    }

    // If there are K beams on the last line and (N1, ... Nk) ways to reach them respectively,
    // the answer (total number of paths in the grid) is N1 + N2 + ... + Nk
    long result = 0;
    for (BeamData lastLineBeam: every_beam.get(line_count-1)) {
      result += lastLineBeam.nb_paths;
    }
    System.out.printf("%d\n", result);
  }
}
