import std;
using namespace std;

auto main() -> int {
  constexpr auto directions = std::to_array<pair<int8_t, int8_t>>({
    {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}
  });
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

  auto const nb_rows = matrix.size();
  auto const nb_cols = matrix[0].size();
  size_t result = 0;
  for (auto i = 0; i < nb_rows; ++i) {
    for (auto j = 0; j < nb_cols; ++j) {
      if (matrix[i][j] != '@') continue;

      uint8_t nb_neighbors = 0;
      for (auto const& [delta_row, delta_col] : directions) { // e.g. [-1, +1]
        // The indexes of the neighbor we'll check
        int idx_row = static_cast<int>(i) + delta_row;
        int idx_col = static_cast<int>(j) + delta_col;
        if (idx_row < 0 || idx_row >= nb_rows || idx_col < 0 || idx_col >= nb_cols) {
          continue;
        }

        if (matrix[idx_row][idx_col] == '@') {
          ++nb_neighbors;
        }
      }

      if (nb_neighbors < 4) {
        ++result;
      }
    }
  }

  println("{}", result);
  return 0;
}
