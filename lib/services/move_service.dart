// lib/services/move_service.dart
// Kişi 4 – Doğru/Yanlış İşlem sorumluluğu
//
// Şunları yönetir:
//   1. Doğru hamle: blok patlatma + compact + yeni target
//   2. Yanlış hamle: sayaç artırma + 3'te ceza
//   3. Ceza: tüm sütunlara üstten blok indirme

import 'dart:math';
import '../models/block_model.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class MoveService {
  final Random _random = Random();

  // ─────────────────────────────────────────────
  // 1. DOĞRU HAMLEVILIGİ
  // ─────────────────────────────────────────────

  /// Seçili blokları patlatır, üstteki blokları kaydırır,
  /// puanı günceller ve yeni hedef üretir.
  GameState handleCorrectMove(GameState state) {
    // Seçilen hücrelerin koordinatlarını al
    final selected = state.selectionChain;

    // Puan hesapla (kPointValues tablosuna göre)
    int earned = 0;
    for (final b in selected) {
      earned += kPointValues[b.number] ?? 0;
    }

    // Grid kopyasını al ve seçili hücreleri boşalt
    final newGrid = _copyGrid(state.grid);
    for (final b in selected) {
      newGrid[b.row][b.col] = null;
    }

    // Her sütunu aşağı kaydır (compact)
    _compactGrid(newGrid);

    // Yeni puan
    final newScore = state.score + earned;

    // Yeni hedef sayı üret
    final newTarget = _generateTarget(newGrid, newScore);

    return state.copyWith(
      grid: newGrid,
      score: newScore,
      targetNumber: newTarget,
      wrongCount: 0, // doğru hamlede yanlış sayacı sıfırla
      selectionChain: [],
    );
  }

  // ─────────────────────────────────────────────
  // 2. YANLIŞ HAMLE
  // ─────────────────────────────────────────────

  /// wrongCount'u artırır. 3'e ulaşırsa ceza uygular.
  GameState handleWrongMove(GameState state) {
    final newWrong = state.wrongCount + 1;

    if (newWrong >= kMaxWrongMoves) {
      // Ceza: tüm sütunlara blok indir, sayacı sıfırla
      final penalized = _applyPenalty(state);
      return penalized.copyWith(wrongCount: 0, selectionChain: []);
    }

    return state.copyWith(wrongCount: newWrong, selectionChain: []);
  }

  // ─────────────────────────────────────────────
  // 3. CEZA MEKANİZMASI
  // ─────────────────────────────────────────────

  /// Tüm sütunların tepesine 1 blok indirir (akış diyagramına göre).
  /// Eğer herhangi sütunun 0. satırı doluysa oyun biter.
  GameState _applyPenalty(GameState state) {
    final newGrid = _copyGrid(state.grid);

    // Her sütuna üstten yeni blok ekle: tüm satırları 1 aşağı kaydır,
    // row 0'a yeni blok yaz
    for (int col = 0; col < kGridCols; col++) {
      // En alta yer var mı kontrol et; yoksa zaten dolmuş (game over)
      // Satırları aşağıdan yukarı kaydır
      for (int row = kGridRows - 1; row > 0; row--) {
        newGrid[row][col] = newGrid[row - 1][col]?.copyWith(row: row);
      }
      // 0. satıra yeni blok
      newGrid[0][col] = BlockModel(
        number: _random.nextInt(9) + 1,
        row: 0,
        col: col,
      );
    }

    // Oyun sonu kontrolü: herhangi son satır doldu mu?
    final isGameOver = newGrid[kGridRows - 1].any((c) => c != null);

    return state.copyWith(grid: newGrid, isGameOver: isGameOver);
  }

  // ─────────────────────────────────────────────
  // YARDIMCI: COMPACT (üstekiler aşağı kayar)
  // ─────────────────────────────────────────────

  /// Her sütunda null olmayan blokları alta yığar (yerçekimi efekti).
  void _compactGrid(List<List<BlockModel?>> grid) {
    for (int col = 0; col < kGridCols; col++) {
      // Sütundaki dolu hücreleri topla
      final blocks = <BlockModel>[];
      for (int row = 0; row < kGridRows; row++) {
        if (grid[row][col] != null) blocks.add(grid[row][col]!);
      }
      // Sütunu temizle
      for (int row = 0; row < kGridRows; row++) {
        grid[row][col] = null;
      }
      // Blokları alta yaz (row güncelle)
      int writeRow = kGridRows - 1;
      for (int i = blocks.length - 1; i >= 0; i--) {
        grid[writeRow][col] = blocks[i].copyWith(row: writeRow);
        writeRow--;
      }
    }
  }

  // ─────────────────────────────────────────────
  // YARDIMCI: HEDEF SAYI ÜRETME
  // ─────────────────────────────────────────────

  /// Grid'deki komşu blok gruplarından ulaşılabilir bir hedef üretir.
  /// Grid çok boşsa basit random döner.
  int _generateTarget(List<List<BlockModel?>> grid, int score) {
    final candidates = <int>[];

    for (int r = 0; r < kGridRows; r++) {
      for (int c = 0; c < kGridCols; c++) {
        if (grid[r][c] == null) continue;
        _findGroups(grid, r, c, [], candidates);
      }
    }

    if (candidates.isEmpty) return 2 + _random.nextInt(17);
    candidates.shuffle();
    return candidates.first;
  }

  /// DFS ile 2-4 uzunluklu komşu grup toplamlarını bulur.
  void _findGroups(
    List<List<BlockModel?>> grid,
    int row,
    int col,
    List<int> visited,
    List<int> candidates,
  ) {
    final key = row * 10 + col;
    if (visited.contains(key)) return;
    if (grid[row][col] == null) return;
    if (visited.length >= kMaxBlocksPerMove) return;

    visited.add(key);

    if (visited.length >= kMinBlocksPerMove) {
      final sum = visited
          .map((k) => grid[k ~/ 10][k % 10]!.number)
          .reduce((a, b) => a + b);
      candidates.add(sum);
    }

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (nr < 0 || nr >= kGridRows || nc < 0 || nc >= kGridCols) continue;
        if (grid[nr][nc] == null) continue;
        _findGroups(grid, nr, nc, List.from(visited), candidates);
      }
    }
  }

  // ─────────────────────────────────────────────
  // YARDIMCI: GRİD KOPYALAMA
  // ─────────────────────────────────────────────

  List<List<BlockModel?>> _copyGrid(List<List<BlockModel?>> original) {
    return List.generate(
      original.length,
      (r) => List.generate(original[r].length, (c) => original[r][c]),
    );
  }
}
