import std;
using namespace std;

// iRemoveRolls remove eligible rolls (part 2 algorithm)
// ioMatrix mutability is actually not needed for part 1...
size_t processRolls(std::vector<std::string>& ioMatrix, bool iRemoveRolls=false) {
  constexpr auto directions = std::to_array<pair<int, int>>({
    {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}
  });

  auto const nb_rows = ioMatrix.size();
  auto const nb_cols = (nb_rows) ? ioMatrix[0].size() : 0;
  size_t result = 0;
  for (size_t i = 0; i < nb_rows; ++i) {
    for (size_t j = 0; j < nb_cols; ++j) {
      if (ioMatrix[i][j] != '@') continue;

      uint8_t nb_neighbors = 0;
      for (auto const& [delta_row, delta_col] : directions) { // e.g. [-1, +1]
        // The indexes of the neighbor we'll check
        int idx_row = static_cast<int>(i) + delta_row;
        int idx_col = static_cast<int>(j) + delta_col;
        if (idx_row < 0 || idx_row >= nb_rows || idx_col < 0 || idx_col >= nb_cols) {
          continue;
        }

        if (ioMatrix[idx_row][idx_col] == '@') {
          ++nb_neighbors;
          if (nb_neighbors == 4) { // no need to continue
            break;
          }
        }
      }

      if (nb_neighbors < 4) {
        ++result;
        if (iRemoveRolls) {
          ioMatrix[i][j] = '.'; // This may allow neighbors to be removed themselves during the current iteration (which is fine)
        }
      }
    }
  }
  return result;
}

auto main() -> int {
  vector<string> matrix;
  { // Fill in matrix
    ifstream file("input.txt");
    if (!file.is_open()) {
      println("Error opening input.txt!");
      return 1;
    }

    string line;
    while (std::getline(file, line)) {
      matrix.push_back(line);
    }
  }

  size_t const result_1 = processRolls(matrix);
  println("{}", result_1);
    
  size_t result_2 = 0, nb_processed = 0;
  do {
    nb_processed = processRolls(matrix, true);
    result_2 += nb_processed;
  } while(nb_processed != 0);
  println("{}", result_2);
  
  return 0;
}
