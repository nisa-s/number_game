// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/game_grid.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/name_entry_screen.dart';

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
        title: 'Number Chain Game',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F23),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C4DFF),
            secondary: Color(0xFF00E5FF),
          ),
        ),
        home: const NameEntryScreen(),
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
            _TopBar(
              score: state.score,
              targetNumber: state.targetNumber,
              wrongCount: state.wrongCount,
              dropInterval: state.dropIntervalSeconds,
              onLeaderboard: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: state.isGameOver
                    ? _GameOverOverlay(
                        score: state.score,
                        correctMoves: state.correctMoves,
                        totalWrongMoves: state.totalWrongMoves,
                        penaltyCount: state.penaltyCount,
                        elapsedSeconds: state.elapsedSeconds,
                      )
                    : const GameGrid(),
              ),
            ),
            const SizedBox(height: 8),
            _BottomBar(
              onStart: provider.startGame,
              onRestart: provider.restartGame,
              onConfirm: provider.confirmMove,
              chainLength: state.selectionChain.length,
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
  final VoidCallback onLeaderboard;

  const _TopBar({
    required this.score,
    required this.targetNumber,
    required this.wrongCount,
    required this.dropInterval,
    required this.onLeaderboard,
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
          // Puan + liderlik butonu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoChip(label: 'SCORE', value: '$score'),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onLeaderboard,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.leaderboard,
                          color: Color(0xFF00E5FF), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'TOP 10',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Hedef sayı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TARGET',
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
                label: 'MISTAKES',
                value: '$wrongCount/3',
                valueColor: wrongCount >= 2 ? Colors.red : null,
              ),
              const SizedBox(height: 4),
              _InfoChip(label: 'SPEED', value: '${dropInterval}s'),
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
  final int chainLength;

  const _BottomBar({
    required this.onStart,
    required this.onRestart,
    required this.onConfirm,
    required this.chainLength,
  });

  @override
  Widget build(BuildContext context) {
    final canConfirm = chainLength >= 2 && chainLength <= 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _GameButton(
              label: 'START',
              color: const Color(0xFF00E5FF),
              onPressed: onStart,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _GameButton(
              label: chainLength > 0 ? 'CHAIN ($chainLength) ✓' : 'CHAIN ✓',
              color: canConfirm
                  ? const Color(0xFF7C4DFF)
                  : const Color(0xFF4A4A6A),
              onPressed: canConfirm ? onConfirm : () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _GameButton(
              label: 'RESTART',
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
        backgroundColor: color.withValues(alpha: 0.2),
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
// OYUN SONU EKRANI (İSTATİSTİKLİ)
// ─────────────────────────────────────────────────────────────────

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int correctMoves;
  final int totalWrongMoves;
  final int penaltyCount;
  final int elapsedSeconds;

  const _GameOverOverlay({
    required this.score,
    required this.correctMoves,
    required this.totalWrongMoves,
    required this.penaltyCount,
    required this.elapsedSeconds,
  });

  String get _formattedTime {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF6E40), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6E40).withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFFF6E40),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),

              // Puan
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'PUAN',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A4A)),
              const SizedBox(height: 16),

              // İstatistikler
              _StatRow(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF4CAF50),
                label: 'Doğru Hamle',
                value: '$correctMoves',
              ),
              const SizedBox(height: 10),
              _StatRow(
                icon: Icons.cancel_outlined,
                iconColor: const Color(0xFFE53935),
                label: 'Yanlış Hamle',
                value: '$totalWrongMoves',
              ),
              const SizedBox(height: 10),
              _StatRow(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFFF9800),
                label: 'Ceza Sayısı',
                value: '$penaltyCount',
              ),
              const SizedBox(height: 10),
              _StatRow(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF00E5FF),
                label: 'Süre',
                value: _formattedTime,
              ),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A4A)),
              const SizedBox(height: 16),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.leaderboard, size: 16),
                      label: const Text('TABLO'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00E5FF),
                        side: const BorderSide(color: Color(0xFF00E5FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      // _GameOverOverlay içindeki butonu bul, şöyle değiştir:
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NameEntryScreen()),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('TEKRAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6E40),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
