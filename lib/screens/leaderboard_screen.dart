// lib/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../models/score_entry.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = LeaderboardService.scores;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'LİDERLİK TABLOSU',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF4A4A6A)),
        ),
      ),
      body: scores.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scores.length,
              itemBuilder: (context, index) {
                return _ScoreCard(entry: scores[index], rank: index + 1);
              },
            ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final ScoreEntry entry;
  final int rank;

  const _ScoreCard({required this.entry, required this.rank});

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // altın
      case 2:
        return const Color(0xFFC0C0C0); // gümüş
      case 3:
        return const Color(0xFFCD7F32); // bronz
      default:
        return const Color(0xFF4A4A6A);
    }
  }

  IconData get _rankIcon {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree
              ? _rankColor.withValues(alpha: 0.6)
              : const Color(0xFF2A2A4A),
          width: isTopThree ? 1.5 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _rankColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Sıra / ikon
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Icon(_rankIcon, color: _rankColor, size: isTopThree ? 22 : 16),
                Text(
                  '#$rank',
                  style: TextStyle(
                    color: _rankColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // İsim
          Expanded(
            child: Text(
              entry.playerName,
              style: TextStyle(
                color: isTopThree ? Colors.white : Colors.white70,
                fontSize: isTopThree ? 16 : 14,
                fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          // Tarih
          Text(
            _formatDate(entry.date),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(width: 12),
          // Puan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _rankColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rankColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${entry.score}',
              style: TextStyle(
                color: _rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            'Henüz skor yok',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bir oyun oyna ve ilk sırayı kap!',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
