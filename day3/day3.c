#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(void) {
  FILE* fp = fopen("input.txt", "r");
  if (!fp) {
    perror("Couldn't open input.txt");
    return 1;
  }

  char* line = NULL;
  size_t len = 0, result = 0;
  ssize_t read;
  while ((read = getline(&line, &len, fp)) != -1) {
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
    result += d1*10 + d2;
  }

  fclose(fp);
  if (line) {
    free(line);
  }

  printf("%zu\n", result);
  return 0;
}
