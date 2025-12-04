#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

size_t part1_algo(ssize_t read, char* line) {
  // Find the greatest digit d1 = line[idx1], i1 in line[0:last-1] (included)
  // Then find the greatest digit d2 = line[idx2], i2 in line[d+1:last]
  uint8_t d1 = 0, d2 = 0;
  int idx1 = 0;
  for (int i = 0; i < read - 2; i++) { // /!\ newline char at line[read-1] so penultimate (where I want to stop) at line[read-3]
    int cur_digit = line[i] - '0';
    if (cur_digit > d1) {
      d1 = cur_digit;
      idx1 = i;
    }
  }
  for (int i = idx1 + 1; i < read - 1; i++) {
    int cur_digit = line[i] - '0';
    if (cur_digit > d2) {
      d2 = cur_digit;
    }
  }
  return d1*10 + d2;
}

size_t part2_algo(ssize_t read, char* line) {
  // The principle is still the same with 12 numbers. We look first for
  // the greatest digit that has at least 11 other characters after it.
  // Then the greatest digit that is after the first one, and has at least
  // 10 other characters after it...
  int lbound = -1;
  uint8_t d[12] = {0};
  for (int k = 0; k < 12; k++) { // Let's find the kth digit
    for (int i = lbound + 1; i < read - 12 + k; i++) {
      int cur_digit = line[i] - '0';
      if (cur_digit > d[k]) {
        d[k] = cur_digit;
        lbound = i;
      }
    }
  } /// Generalization makes the solution even more concise than in part one.

  // Convert d[] to a size_t
  size_t result = 0;
  for (int power = 0; power < 12; power++) {
    result += d[12-power-1] * pow(10, power);
  }
  return result;
}

int main(void) {
  FILE* fp = fopen("input.txt", "r");
  if (!fp) {
    perror("Couldn't open input.txt");
    return 1;
  }

  char* line = NULL;
  size_t len = 0, result_1 = 0, result_2 = 0;
  ssize_t read;
  while ((read = getline(&line, &len, fp)) != -1) {
    result_1 += part1_algo(read, line);
    result_2 += part2_algo(read, line);
  }

  fclose(fp);
  if (line) {
    free(line);
  }

  printf("%zu\n", result_1);
  printf("%zu\n", result_2);
  return 0;
}
