// lib/main.dart
// Kişi 2 – Düşme Mekaniği sorumluluğu

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/game_grid.dart';

void main() {
  runApp(const StrategicNumberGame());
}

class StrategicNumberGame extends StatelessWidget {
  const StrategicNumberGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Stratejik Sayı Birleştirme',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F23),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C4DFF),
            secondary: Color(0xFF00E5FF),
          ),
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Üst bilgi çubuğu ──────────────────────────────
            _TopBar(
              score: state.score,
              targetNumber: state.targetNumber,
              wrongCount: state.wrongCount,
              dropInterval: state.dropIntervalSeconds,
            ),

            const SizedBox(height: 8),

            // ── Oyun gridi ────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: state.isGameOver
                    ? _GameOverOverlay(score: state.score)
                    : const GameGrid(),
              ),
            ),

            const SizedBox(height: 8),

            // ── Alt kontrol çubuğu ────────────────────────────
            _BottomBar(
              onStart: provider.startGame,
              onRestart: provider.restartGame,
              onConfirm: provider.confirmMove, // Kişi 4 dolduracak
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ÜST BİLGİ ÇUBUĞU
// ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int score;
  final int targetNumber;
  final int wrongCount;
  final int dropInterval;

  const _TopBar({
    required this.score,
    required this.targetNumber,
    required this.wrongCount,
    required this.dropInterval,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(bottom: BorderSide(color: Color(0xFF4A4A6A))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Puan
          _InfoChip(label: 'PUAN', value: '$score'),

          // Hedef sayı (Kişi 3 tarafından kullanılacak)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha:0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HEDEF',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '$targetNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Yanlış sayısı ve hız
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _InfoChip(
                label: 'YANLIŞ',
                value: '$wrongCount/3',
                valueColor: wrongCount >= 2 ? Colors.red : null,
              ),
              const SizedBox(height: 4),
              _InfoChip(label: 'HIZ', value: '${dropInterval}sn'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ALT KONTROL ÇUBUĞU
// ─────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onRestart;
  final VoidCallback onConfirm;

  const _BottomBar({
    required this.onStart,
    required this.onRestart,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Başlat butonu
          Expanded(
            child: _GameButton(
              label: 'BAŞLAT',
              color: const Color(0xFF00E5FF),
              onPressed: onStart,
            ),
          ),
          const SizedBox(width: 8),

          // Onayla butonu (Kişi 4'ün mantığını tetikler)
          Expanded(
            flex: 2,
            child: _GameButton(
              label: 'ONAYLA ✓',
              color: const Color(0xFF7C4DFF),
              onPressed: onConfirm,
            ),
          ),
          const SizedBox(width: 8),

          // Yeniden başlat
          Expanded(
            child: _GameButton(
              label: 'YENİDEN',
              color: const Color(0xFFFF6E40),
              onPressed: onRestart,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _GameButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha:0.2),
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// OYUN SONU EKRANI
// ─────────────────────────────────────────────────────────────────

class _GameOverOverlay extends StatelessWidget {
  final int score;

  const _GameOverOverlay({required this.score});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF6E40), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6E40).withValues(alpha:0.3),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'OYUN BİTTİ',
              style: TextStyle(
                color: Color(0xFFFF6E40),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Skorun: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<GameProvider>().restartGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6E40),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'TEKRAR OYNA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}