#include <algorithm>
#include <iomanip>
#include <iostream>
#include <string>

int main() {
  std::string seq1{"ACACACTA"};
  std::string seq2{"AGCACACA"};
  // std::string seq1{"CAAGAATGTCACAGGTCCAT"};
  // std::string seq2{"CAGCATCACACTTA"};

  int H[seq2.length() + 1][seq1.length() + 1];
  std::fill_n(reinterpret_cast<int *>(H), sizeof(H) / sizeof(int), 0);

  for (int i = 0; i < seq2.length(); ++i)
    for (int j = 0; j < seq1.length(); ++j) {
      int match_or_mismatch = seq2[i] == seq1[j] ? H[i][j] + 3 : H[i][j] - 1;
      int gap = std::max(H[i + 1][j], H[i][j + 1]) - 2;
      H[i + 1][j + 1] = std::max(std::max(match_or_mismatch, gap), 0);
    }

  for (int i = 0; i <= seq2.length(); ++i) {
    for (int j = 0; j <= seq1.length(); ++j) {
      std::cout << std::setw(4) << H[i][j] << ' ';
    }
    std::cout << '\n';
  }
  std::cout << std::flush;

  int max_i = 0, max_j = 0, max = 0;
  for (int i = 1; i <= seq2.length(); ++i)
    for (int j = 1; j <= seq1.length(); ++j)
      if (H[i][j] > max) {
        max_i = i;
        max_j = j;
        max = H[i][j];
      }

  int i = max_i, j = max_j, cur = max;
  while (cur) {
    if (seq2[i - 1] == seq1[j - 1] || H[i - 1][j - 1] - 1 == cur) {
      cur = H[i - 1][j - 1];
      --i;
      --j;
      std::cout << '3';
    } else if (H[i - 1][j] - 1 == cur) {
      cur = H[i - 1][j];
      --i;
      std::cout << '2';
    } else {
      cur = H[i][j - 1];
      --j;
      std::cout << '1';
    }
  }
  std::cout << std::endl;
  return 0;
}