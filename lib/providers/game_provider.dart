// lib/providers/game_provider.dart
// Ortak – Kişi 1 & Kişi 2 birlikte
//
// Provider, GameState'i tutar ve DropService ile UI arasındaki
// köprüyü kurar. Kişi 3 ve 4'ün ekleyeceği seçim/hedef mantığı
// da buraya gelecektir.

import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/drop_service.dart';

class GameProvider extends ChangeNotifier {
  late GameState _state;
  late DropService _dropService;

  GameState get state => _state;

  GameProvider() {
    _state = GameState.initial();
    _dropService = DropService(
      onStateChanged: _applyState,
    );
  }

  // ─────────────────────────────────────────────
  // OYUN KONTROL
  // ─────────────────────────────────────────────

  /// Oyunu başlatır: timer çalışmaya başlar.
  void startGame() {
    _state = GameState.initial();
    notifyListeners();
    _dropService.startDropTimer(() => _state);
  }

  /// Oyunu duraklatır.
  void pauseGame() {
    _dropService.stopDropTimer();
  }

  /// Devam ettirir.
  void resumeGame() {
    _dropService.startDropTimer(() => _state);
  }

  /// Oyunu yeniden başlatır.
  void restartGame() {
    _dropService.stopDropTimer();
    startGame();
  }

  // ─────────────────────────────────────────────
  // STATE GÜNCELLEME (DropService callback'i)
  // ─────────────────────────────────────────────

  void _applyState(GameState newState) {
    final oldInterval = _state.dropIntervalSeconds;
    _state = newState;
    notifyListeners();

    if (_state.isGameOver) {
      _dropService.stopDropTimer();
      return;
    }

    // Puan değişince timer hızını güncelle
    if (newState.dropIntervalSeconds != oldInterval) {
      _dropService.refreshTimerSpeed(() => _state);
    }
  }

  // ─────────────────────────────────────────────
  // KİŞİ 3 & 4 İÇİN PLACEHOLDER'LAR
  // (Bu metodlar Kişi 3 ve 4 tarafından doldurulacak)
  // ─────────────────────────────────────────────

  /// Kişi 3: Blok seçim zinciri
  void selectBlock(int row, int col) {
    // 1. Komşuluk kontrolü yap (yatay, dikey, çapraz)
    // 2. Seçim sınırını kontrol et (en az 2, en fazla 4 blok)
    // 3. Bloğu seçili işaretle ve zincire ekle
  }

  /// Kişi 4: Onay butonu – seçili blokları doğrula
  void confirmMove() {
    // 1. Toplamı kontrol et (sum == targetNumber?)
    // 2. Doğruysa: handleCorrectMove() çağır (Puan ekle, patlat, hız kontrol)
    // 3. Yanlışsa: handleWrongMove() çağır (wrongCount++, ceza kontrol)
    // 4. Her durumda: clearChain() (Seçimi temizle)
  }

  /// Kişi 4: Yanlış seçim sayacını artır
  void incrementWrongCount() {
    // 1. wrongCount değerini artır
    // 2. Eğer 3 olduysa ceza uygula (tüm sütunlara blok indir)
    // 3. Sayacı sıfırla
  }

  @override
  void dispose() {
    _dropService.dispose();
    super.dispose();
  }
}