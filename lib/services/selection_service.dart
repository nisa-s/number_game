// lib/services/selection_service.dart

import '../models/block_model.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class SelectionService {
  // ─────────────────────────────────────────────
  // 1. BLOK SEÇİMİ
  // ─────────────────────────────────────────────

  /// Bloğa dokunulduğunda zinciri günceller.
  /// - Zincir boşsa ilk bloğu ekle
  /// - Zaten seçiliyse o noktadan geri al (backtrack)
  /// - Komşuysa ve limit dolmamışsa ekle
  GameState onBlockTap(GameState state, int row, int col) {
    final block = state.grid[row][col];
    if (block == null) return state;

    final chain = List<BlockModel>.from(state.selectionChain);

    // Zincir boşsa direkt ekle
    if (chain.isEmpty) {
      block.isSelected = true;
      chain.add(block);
      return state.copyWith(selectionChain: chain);
    }

    // Zaten zincirdeyse backtrack yap
    final idx = chain.indexWhere((b) => b.row == row && b.col == col);
    if (idx != -1) {
      for (int i = idx; i < chain.length; i++) {
        chain[i].isSelected = false;
      }
      chain.removeRange(idx, chain.length);
      return state.copyWith(selectionChain: chain);
    }

    // Max 4 blok kontrolü
    if (chain.length >= kMaxBlocksPerMove) return state;

    // Komşuluk kontrolü
    final last = chain.last;
    if (!_isAdjacent(last.row, last.col, row, col)) return state;

    block.isSelected = true;
    chain.add(block);
    return state.copyWith(selectionChain: chain);
  }

  /// Seçim zincirini tamamen temizler.
  GameState clearChain(GameState state) {
    for (final b in state.selectionChain) {
      b.isSelected = false;
    }
    return state.copyWith(selectionChain: []);
  }

  // ─────────────────────────────────────────────
  // 2. KOMŞULUK KONTROLÜ
  // ─────────────────────────────────────────────

  /// 8 yönlü komşuluk: |dr| ≤ 1 ve |dc| ≤ 1, aynı hücre değil
  bool _isAdjacent(int r1, int c1, int r2, int c2) {
    final dr = (r1 - r2).abs();
    final dc = (c1 - c2).abs();
    return dr <= 1 && dc <= 1 && !(dr == 0 && dc == 0);
  }

  // ─────────────────────────────────────────────
  // 3. HEDEf SAYI ÜRETME
  // ─────────────────────────────────────────────

  /// Gride bakarak ulaşılabilir bir hedef sayı üretir.
  /// Grid'deki komşu grup toplamlarından random seçer.
  /// Geçerli grup yoksa fallback olarak basit random döner.
  int generateTarget(GameState state) {
    final candidates = <int>[];

    for (int r = 0; r < kGridRows; r++) {
      for (int c = 0; c < kGridCols; c++) {
        if (state.grid[r][c] == null) continue;
        // Bu bloktan başlayan 2-4 uzunluklu komşu grupları bul
        _findGroups(state, r, c, [], candidates);
      }
    }

    if (candidates.isEmpty) {
      // Grid çok boşsa basit random (2-18 arası)
      return 2 + DateTime.now().millisecond % 17;
    }

    candidates.shuffle();
    return candidates.first;
  }

  /// DFS ile komşu gruplar bulur, toplamlarını candidates'e ekler.
  void _findGroups(
    GameState state,
    int row,
    int col,
    List<int> visited, // [r*10+c] formatında
    List<int> candidates,
  ) {
    final key = row * 10 + col;
    if (visited.contains(key)) return;
    if (state.grid[row][col] == null) return;
    if (visited.length >= kMaxBlocksPerMove) return;

    visited.add(key);

    // En az 2 bloksa toplamı candidate olarak ekle
    if (visited.length >= kMinBlocksPerMove) {
      final sum = visited
          .map((k) => state.grid[k ~/ 10][k % 10]!.number)
          .reduce((a, b) => a + b);
      candidates.add(sum);
    }

    // Komşulara git
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (nr < 0 || nr >= kGridRows || nc < 0 || nc >= kGridCols) continue;
        if (state.grid[nr][nc] == null) continue;
        final nKey = nr * 10 + nc;
        if (visited.contains(nKey)) continue;
        _findGroups(state, nr, nc, List.from(visited), candidates);
      }
    }
  }
}
