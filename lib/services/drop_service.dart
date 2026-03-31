// lib/services/drop_service.dart
// Kişi 2 – Düşme Mekaniği sorumluluğu
//
// Bu servis şu işlemleri yönetir:
//   1. Üstten rastgele blok üretme
//   2. Bloğu her X saniyede bir aşağı kaydıran Timer
//   3. Bloğun tabana veya başka bloğun üstüne oturma kontrolü

import 'dart:async';
import 'dart:math';
import '../models/block_model.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class DropService {
  Timer? _dropTimer;
  final Random _random = Random();

  // GameProvider bu callback'i dinleyerek state'i günceller
  final void Function(GameState newState) onStateChanged;

  DropService({required this.onStateChanged});

  // ─────────────────────────────────────────────
  // 1. BLOK ÜRETME
  // ─────────────────────────────────────────────

  /// Üstten yeni bir blok üretir ve rastgele bir sütuna yerleştirir.
  /// Dönen GameState'de fallingBlock, fallingRow=0, fallingCol atanmıştır.
  GameState spawnNewBlock(GameState state) {
    // Boş bir sütun seç (tüm sütunlar doluysa oyun zaten bitmeli)
    final availableCols = <int>[];
    for (int col = 0; col < kGridCols; col++) {
      if (state.grid[0][col] == null) {
        availableCols.add(col);
      }
    }

    // Kullanılabilir sütun yoksa oyun sonu sinyali ver
    if (availableCols.isEmpty) {
      return state.copyWith(isGameOver: true);
    }

    final col = availableCols[_random.nextInt(availableCols.length)];
    final newBlock = BlockModel(number: _random.nextInt(9) + 1);

    return state.copyWith(
      fallingBlock: newBlock,
      fallingRow: 0,
      fallingCol: col,
    );
  }

  // ─────────────────────────────────────────────
  // 2. DÜŞME ZAMANLAYICISI
  // ─────────────────────────────────────────────

  /// Timer'ı başlatır. Her tick'te bloğu bir satır aşağı iter.
  /// [state] parametresi getter olarak verilir çünkü
  /// her tick'te güncel state lazım.
  void startDropTimer(GameState Function() getState) {
    _dropTimer?.cancel();

    final intervalSec = getState().dropIntervalSeconds;

    _dropTimer = Timer.periodic(
      Duration(seconds: intervalSec),
      (_) {
        final current = getState();
        if (current.isGameOver) {
          stopDropTimer();
          return;
        }

        // Henüz düşen blok yoksa yeni üret
        if (current.fallingBlock == null) {
          final spawned = spawnNewBlock(current);
          onStateChanged(spawned);
          return;
        }

        // Bloğu bir adım aşağı kaydır
        final next = _stepDown(current);
        onStateChanged(next);
      },
    );
  }

  /// Timer'ı durdurur (oyun sonu veya duraklatma için).
  void stopDropTimer() {
    _dropTimer?.cancel();
    _dropTimer = null;
  }

  /// Puan değiştiğinde Timer hızını günceller.
  /// Eski timer iptal edilir, yeni interval ile yeniden başlatılır.
  void refreshTimerSpeed(GameState Function() getState) {
    stopDropTimer();
    startDropTimer(getState);
  }

  // ─────────────────────────────────────────────
  // 3. TABANA / BLOĞA OTURMA MANTIĞI
  // ─────────────────────────────────────────────

  /// Düşen bloğu bir satır aşağı kaydırır.
  /// Eğer bir sonraki satır dolu ya da taban ise bloğu grida sabitler.
  GameState _stepDown(GameState state) {
    final block = state.fallingBlock!;
    final row = state.fallingRow!;
    final col = state.fallingCol!;

    final nextRow = row + 1;

    // Oturma kontrolü: taban mı yoksa altındaki hücre dolu mu?
    final shouldSettle = _shouldSettle(state, nextRow, col);

    if (shouldSettle) {
      // Bloğu grida sabitle
      return _settleBlock(state, block, row, col);
    } else {
      // Sadece bir satır aşağı inin
      return state.copyWith(fallingRow: nextRow);
    }
  }

  /// Bir sonraki satır geçerli mi ve boş mu kontrol eder.
  bool _shouldSettle(GameState state, int nextRow, int col) {
    // Tabana ulaştı mı?
    if (nextRow >= kGridRows) return true;

    // Bir sonraki hücre dolu mu?
    if (state.grid[nextRow][col] != null) return true;

    return false;
  }

  /// Bloğu gridin ilgili hücresine yerleştirir,
  /// falling bilgilerini temizler ve oyun sonu kontrolü yapar.
  GameState _settleBlock(
    GameState state,
    BlockModel block,
    int row,
    int col,
  ) {
    // Grid'in derin kopyasını al
    final newGrid = _copyGrid(state.grid);
    newGrid[row][col] = block;

    // Oyun sonu: herhangi bir sütunun 0. satırı doldu mu?
    final isGameOver = newGrid[0].any((cell) => cell != null);

    return state.copyWith(
      grid: newGrid,
      isGameOver: isGameOver,
      clearFalling: true, // fallingBlock/Row/Col sıfırlanır
    );
  }

  // ─────────────────────────────────────────────
  // YARDIMCI
  // ─────────────────────────────────────────────

  /// Grid'in bağımsız derin kopyasını döner.
  List<List<BlockModel?>> _copyGrid(List<List<BlockModel?>> original) {
    return List.generate(
      original.length,
      (r) => List.generate(original[r].length, (c) => original[r][c]),
    );
  }

  /// Servis serbest bırakılırken çağrılır.
  void dispose() {
    stopDropTimer();
  }
}