// lib/screens/name_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'package:number_game/main.dart' show GameScreen;
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final _controller = TextEditingController();
  String? _errorText;

  void _startGame() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Lütfen bir isim girin');
      return;
    }
    // Provider'a ismi ilet ve oyunu başlat
    context.read<GameProvider>().setPlayerName(name);
    context.read<GameProvider>().startGame();

    // GameScreen'e geç (geri dönemesin diye pushReplacement)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const _GameScreenWrapper()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                const Text(
                  'STRATEJİK',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 14,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'SAYI BİRLEŞTİRME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                // İkon
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C4DFF),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.grid_4x4,
                    color: Color(0xFF7C4DFF),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Oyuna başlamak için\nisminizi girin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                // İsim giriş alanı
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Oyuncu adınız',
                    hintStyle: const TextStyle(color: Colors.white30),
                    errorText: _errorText,
                    counterStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF1A1A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4A4A6A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4A4A6A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF7C4DFF), width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _startGame(),
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Başlat butonu
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor:
                          const Color(0xFF7C4DFF).withValues(alpha: 0.5),
                    ),
                    child: const Text(
                      'OYUNA BAŞLA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// GameScreen'i bu dosyadan da import edebilmek için basit bir wrapper
// Asıl GameScreen main.dart'ta tanımlı, oraya yönlendiriyoruz
class _GameScreenWrapper extends StatelessWidget {
  const _GameScreenWrapper();

  @override
  Widget build(BuildContext context) {
    // main.dart'taki GameScreen'i import et
    // Bu satırı sen main.dart'taki GameScreen ile değiştireceksin
    return const GameScreen(); // → aşağıdaki adımda düzelteceğiz
  }
}
