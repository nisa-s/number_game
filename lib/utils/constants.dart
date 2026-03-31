// lib/utils/constants.dart
// Kişi 1 – Grid & Başlangıç sorumluluğu

const int kGridCols = 8;
const int kGridRows = 10;
const int kInitialFilledRows = 3;

const int kInitialDropIntervalSec = 5;
const int kMinDropIntervalSec = 1;
const int kPointsPerSpeedIncrease = 100;

const int kMinBlocksPerMove = 2;
const int kMaxBlocksPerMove = 4;
const int kMaxWrongMoves = 3;

// Sayılara karşılık gelen puan değerleri
const Map<int, int> kPointValues = {
  1: 1,
  2: 2,
  3: 3,
  4: 5,
  5: 7,
  6: 9,
  7: 12,
  8: 15,
  9: 20,
};