// lib/models/block_model.dart
// Kişi 1 – Grid & Başlangıç sorumluluğu

import 'package:flutter/material.dart';
import '../utils/color_map.dart';

class BlockModel {
  final int number;   // 1-9 arası sayı
  final Color color;  // sayıya atanmış sabit renk
  bool isSelected;    // seçim zincirinde mi?

  BlockModel({
    required this.number,
    this.isSelected = false,
  }) : color = blockColor(number);

  BlockModel copyWith({bool? isSelected}) {
    return BlockModel(number: number)
      ..isSelected = isSelected ?? this.isSelected;
  }

  @override
  String toString() => 'Block($number)';
}