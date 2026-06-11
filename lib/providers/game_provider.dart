// lib/providers/game_provider.dart

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/drop_service.dart';
import '../services/selection_service.dart';
import '../services/move_service.dart';
import '../services/leaderboard_service.dart';

class GameProvider extends ChangeNotifier {
  late GameState _state;
  late DropService _dropService;
  final _selectionService = SelectionService();
  final _moveService = MoveService();

  GameState get state => _state;

  GameProvider() {
    _state = GameState.initial();
    _dropService = DropService(onStateChanged: _applyState);
  }



String playerName = 'Oyuncu'; // sınıfın üstüne ekle

void setPlayerName(String name) {
  playerName = name;
  notifyListeners();
}
  // ── Oyun kontrol (Kişi 1 & 2) ─────────────────
  void startGame() {
    _state = GameState.initial();
    notifyListeners();
    _dropService.startDropTimer(() => _state);
  }

  void pauseGame() => _dropService.stopDropTimer();
  void resumeGame() => _dropService.startDropTimer(() => _state);

  void restartGame() {
    _dropService.stopDropTimer();
    LeaderboardService.addScore('Oyuncu', _state.score);
    startGame();
  }

  void _applyState(GameState newState) {
    final oldInterval = _state.dropIntervalSeconds;
    _state = newState;
    notifyListeners();
    if (_state.isGameOver) {
      _dropService.stopDropTimer();
      LeaderboardService.addScore(playerName, _state.score);
      return;
    }
    if (newState.dropIntervalSeconds != oldInterval) {
      _dropService.refreshTimerSpeed(() => _state);
    }
  }

  // ── Kişi 3: Blok seçimi ───────────────────────
  void selectBlock(int row, int col) {
    _state = _selectionService.onBlockTap(_state, row, col);
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // KİŞİ 4: ONAY BUTONU
  // ─────────────────────────────────────────────

  /// Onay butonuna basıldığında:
  /// - Zincir 2-4 arası değilse hiçbir şey yapma
  /// - Sum == target → doğru hamle
  /// - Sum != target → yanlış hamle
  void confirmMove() {
    final chain = _state.selectionChain;

    // Kural: 2 ≤ chain ≤ 4 olmalı (buton zaten disabled ama güvenlik için)
    if (chain.length < 2 || chain.length > 4) return;

    if (_state.chainSum == _state.targetNumber) {
      // Doğru: patlat, kaydır, puanla, yeni target
      _applyState(_moveService.handleCorrectMove(_state));
    } else {
      // Yanlış: sayacı artır, gerekirse ceza uygula
      _applyState(_moveService.handleWrongMove(_state));
    }
  }

  /// Harici yanlış sayacı artırma (gerekirse başka yerden çağrılabilir)
  void incrementWrongCount() {
    _applyState(_moveService.handleWrongMove(_state));
  }

  @override
  void dispose() {
    _dropService.dispose();
    super.dispose();
  }
}
