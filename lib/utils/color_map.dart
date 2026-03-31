// lib/utils/color_map.dart
// Kişi 1 – Grid & Başlangıç sorumluluğu

import 'package:flutter/material.dart';

/// Her sayıya (1-9) atanmış sabit renk
const Map<int, Color> kBlockColors = {
  1: Color(0xFFE53935), // kırmızı
  2: Color(0xFFE91E63), // pembe
  3: Color(0xFF9C27B0), // mor
  4: Color(0xFF3F51B5), // indigo
  5: Color(0xFF2196F3), // mavi
  6: Color(0xFF009688), // teal
  7: Color(0xFF4CAF50), // yeşil
  8: Color(0xFFFF9800), // turuncu
  9: Color(0xFFFF5722), // koyu turuncu
};

Color blockColor(int number) {
  return kBlockColors[number] ?? Colors.grey;
}