// lib/services/leaderboard_service.dart
// Kişi 4 – Liderlik tablosu servisi

import '../models/score_entry.dart';

class LeaderboardService {
  static final List<ScoreEntry> _scores = [];

  // Yeni skor ekle, yüksekten düşüğe sırala, top 10 tut
  static void addScore(String playerName, int score) {
    _scores.add(ScoreEntry(
      playerName: playerName,
      score: score,
      date: DateTime.now(),
    ));
    _scores.sort((a, b) => b.score.compareTo(a.score));
    if (_scores.length > 10) _scores.removeLast();
  }

  static List<ScoreEntry> get scores => List.unmodifiable(_scores);
}