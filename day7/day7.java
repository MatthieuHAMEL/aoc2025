import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.ArrayList;
import java.util.Stack;

// Of course Java doesn't have a tree structure! .....
class HamelTree<T> { 
  public HamelTree(T data) {
    _data = data;
    _children = new ArrayList<HamelTree<T>>();
  }
  public HamelTree<T> addChild(T child_data) {
    // Use the private ctor to increase the depth
    var child = new HamelTree<T>(child_data, _depth+1);
    _children.add(child);
    return child;
  }

  public T getData() {
    return _data;
  }
  
  public HamelTree<T> getChild(int idx) {
    return _children.get(idx);
  }

  public int getNumberOfChildren() {
    return _children.size();
  }

  public int getDepth() {
    return _depth;
  }

  private HamelTree(T data, int depth) {
    this(data);
    _depth = depth;
  }
  private T _data;
  private ArrayList<HamelTree<T>> _children;
  private int _depth;
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
    int i = 0;
    while (scanner.hasNextLine()) {
      data_in[i++] = scanner.nextLine().toCharArray();
    }

    // Store the index relatively to the line (the line index itself is the depth)
    // /!\ don't use Arrays.toString which gives a "pretty print" version of the char array!
    // Ideally I shouldn't use strings at all - if only there were some kind of indexOf on arrays
    // But solutions to that (rather simple) problem are "use C#", "use guava", or "write your own loop".
    // https://stackoverflow.com/questions/4962361/where-is-javas-array-indexof#19084357
    // Java is such a depressing language!
    var root_tree = new HamelTree<Integer>(String.valueOf(data_in[0]).indexOf('S'));
    var nodes = new Stack<HamelTree<Integer>>();
    nodes.push(root_tree);

    // Build the tree starting with the root
    int nb_split = 0;
    while (!nodes.isEmpty()) {
      var node = nodes.pop();
      
      // Look at the cell below the current index
      int y_next = node.getDepth() + 1; // the next line index
      int x = node.getData(); // the horizontal index of the current node
      if (y_next == line_count) {
        continue; // Last line reached => nothing to do
      }
      String next_line = String.valueOf(data_in[y_next]);
      if (next_line.charAt(x) == '.') {
        // The tachyon doesn't split, I create a child at depth+1
        // (the depth is set by the HamelTree), and I reference it in the stack.
        nodes.push(node.addChild(x)); // same horizontal index!
        data_in[y_next][x] = '|';
      }
      else if (next_line.charAt(x) == '|') { // already visited
        continue;
      }
      else { // '^' : split the tachyon left & right
        nb_split++;
        if (x - 1 > 0 && next_line.charAt(x-1) == '.') {
          nodes.push(node.addChild(x-1));
          data_in[y_next][x-1] = '|';
        }
        if (x + 1 < next_line.length() && next_line.charAt(x+1) == '.') {
          nodes.push(node.addChild(x+1));
          data_in[y_next][x+1] = '|';
        }
      }
    }
    
    System.out.printf("%d\n", nb_split);
  }
}
