// lib/models/score_entry.dart
// Kişi 4 – Liderlik tablosu için skor modeli

class ScoreEntry {
  final String playerName;
  final int score;
  final DateTime date;

  ScoreEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });
}