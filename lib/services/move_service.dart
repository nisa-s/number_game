// lib/services/move_service.dart

import 'dart:math';
import '../models/block_model.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class MoveService {
  final Random _random = Random();

  // ─────────────────────────────────────────────
  // 1. DOĞRU HAMLE
  // ─────────────────────────────────────────────

  GameState handleCorrectMove(GameState state) {
    final selected = state.selectionChain;

    int earned = 0;
    for (final b in selected) {
      earned += kPointValues[b.number] ?? 0;
    }

    final newGrid = _copyGrid(state.grid);
    for (final b in selected) {
      newGrid[b.row][b.col] = null;
    }

    _compactGrid(newGrid);

    final newScore = state.score + earned;
    final newTarget = _generateTarget(newGrid, newScore);

    return state.copyWith(
      grid: newGrid,
      score: newScore,
      targetNumber: newTarget,
      wrongCount: 0,
      selectionChain: [],
      correctMoves: state.correctMoves + 1,
    );
  }

  // ─────────────────────────────────────────────
  // 2. YANLIŞ HAMLE
  // ─────────────────────────────────────────────

  GameState handleWrongMove(GameState state) {
    final newWrong = state.wrongCount + 1;
    final newTotalWrong = state.totalWrongMoves + 1;

    if (newWrong >= kMaxWrongMoves) {
      final penalized = _applyPenalty(state);
      return penalized.copyWith(
        wrongCount: 0,
        selectionChain: [],
        totalWrongMoves: newTotalWrong,
        penaltyCount: state.penaltyCount + 1,
      );
    }

    return state.copyWith(
      wrongCount: newWrong,
      selectionChain: [],
      totalWrongMoves: newTotalWrong,
    );
  }

  // ─────────────────────────────────────────────
  // 3. CEZA MEKANİZMASI
  // ─────────────────────────────────────────────

  GameState _applyPenalty(GameState state) {
    final newGrid = _copyGrid(state.grid);

    for (int col = 0; col < kGridCols; col++) {
      int? emptyRow;
      for (int row = kGridRows - 1; row >= 0; row--) {
        if (newGrid[row][col] == null) {
          emptyRow = row;
          break;
        }
      }
      if (emptyRow != null) {
        newGrid[emptyRow][col] = BlockModel(
          number: _random.nextInt(9) + 1,
          row: emptyRow,
          col: col,
        );
      }
    }

    final isGameOver = List.generate(kGridCols, (col) {
      return List.generate(
        kGridRows,
        (row) => newGrid[row][col],
      ).every((b) => b != null);
    }).any((columnFull) => columnFull);

    return state.copyWith(grid: newGrid, isGameOver: isGameOver);
  }

  // ─────────────────────────────────────────────
  // YARDIMCI: COMPACT
  // ─────────────────────────────────────────────

  void _compactGrid(List<List<BlockModel?>> grid) {
    for (int col = 0; col < kGridCols; col++) {
      final blocks = <BlockModel>[];
      for (int row = 0; row < kGridRows; row++) {
        if (grid[row][col] != null) blocks.add(grid[row][col]!);
      }
      for (int row = 0; row < kGridRows; row++) {
        grid[row][col] = null;
      }
      int writeRow = kGridRows - 1;
      for (int i = blocks.length - 1; i >= 0; i--) {
        grid[writeRow][col] = blocks[i].copyWith(row: writeRow);
        writeRow--;
      }
    }
  }

  // ─────────────────────────────────────────────
  // YARDIMCI: HEDEF SAYI
  // ─────────────────────────────────────────────

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

  List<List<BlockModel?>> _copyGrid(List<List<BlockModel?>> original) {
    return List.generate(
      original.length,
      (r) => List.generate(original[r].length, (c) => original[r][c]),
    );
  }
}
