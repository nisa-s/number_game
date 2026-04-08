// lib/models/game_state.dart

import 'dart:math';
import 'block_model.dart';
import '../utils/constants.dart';

class GameState {
  /// 8x10'luk grid. grid[satır][sütun]. null = boş hücre.
  final List<List<BlockModel?>> grid;

  /// Ekranda gösterilen hedef sayı
  final int targetNumber;

  /// Oyuncunun toplam puanı
  final int score;

  /// Arka arkaya yanlış seçim sayısı (3'e ulaşınca ceza)
  final int wrongCount;

  /// Oyun bitti mi?
  final bool isGameOver;

  /// Düşmekte olan bloğun sütun konumu
  final int? fallingCol;

  /// Düşmekte olan bloğun satır konumu
  final int? fallingRow;

  /// Düşmekte olan blok
  final BlockModel? fallingBlock;

  /// Kişi 3: Seçim zinciri – sıralı blok listesi
  final List<BlockModel> selectionChain;

  GameState({
    required this.grid,
    required this.targetNumber,
    this.score = 0,
    this.wrongCount = 0,
    this.isGameOver = false,
    this.fallingCol,
    this.fallingRow,
    this.fallingBlock,
    this.selectionChain = const [],
  });

  /// Başlangıç durumu: son 3 satır rastgele dolu
  factory GameState.initial() {
    final random = Random();
    final grid = List.generate(
      kGridRows,
      (row) => List.generate(
        kGridCols,
        (col) {
          if (row >= kGridRows - kInitialFilledRows) {
            return BlockModel(
              number: random.nextInt(9) + 1,
              row: row,
              col: col,
            );
          }
          return null;
        },
      ),
    );
    return GameState(
      grid: grid,
      targetNumber: _generateTargetNumber(random),
    );
  }

  /// Rastgele hedef sayı üretir (2-36 arası)
  static int _generateTargetNumber(Random random) {
    return random.nextInt(35) + 2;
  }

  /// Puana göre düşme aralığı (saniye)
  int get dropIntervalSeconds {
    if (score >= 400) return 1;
    if (score >= 300) return 2;
    if (score >= 200) return 3;
    if (score >= 100) return 4;
    return kInitialDropIntervalSec;
  }

  /// Belirtilen sütun dolu mu?
  bool isColumnFull(int col) => grid[0][col] != null;

  /// Herhangi bir sütun dolu mu?
  bool get anyColumnFull {
    for (int col = 0; col < kGridCols; col++) {
      if (isColumnFull(col)) return true;
    }
    return false;
  }

  /// Seçim zincirinin toplamı
  int get chainSum =>
      selectionChain.fold(0, (sum, b) => sum + b.number);

  GameState copyWith({
    List<List<BlockModel?>>? grid,
    int? targetNumber,
    int? score,
    int? wrongCount,
    bool? isGameOver,
    int? fallingCol,
    int? fallingRow,
    BlockModel? fallingBlock,
    bool clearFalling = false,
    List<BlockModel>? selectionChain,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      targetNumber: targetNumber ?? this.targetNumber,
      score: score ?? this.score,
      wrongCount: wrongCount ?? this.wrongCount,
      isGameOver: isGameOver ?? this.isGameOver,
      fallingCol: clearFalling ? null : (fallingCol ?? this.fallingCol),
      fallingRow: clearFalling ? null : (fallingRow ?? this.fallingRow),
      fallingBlock: clearFalling ? null : (fallingBlock ?? this.fallingBlock),
      selectionChain: selectionChain ?? this.selectionChain,
    );
  }
}
