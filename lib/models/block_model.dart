// lib/models/block_model.dart

import 'package:flutter/material.dart';
import '../utils/color_map.dart';

class BlockModel {
  final int number;   // 1-9 arası sayı
  final Color color;  // sayıya atanmış sabit renk
  bool isSelected;    // seçim zincirinde mi?
  final int row;      // grid'deki satır konumu
  final int col;      // grid'deki sütun konumu

  BlockModel({
    required this.number,
    required this.row,
    required this.col,
    this.isSelected = false,
  }) : color = blockColor(number);

  BlockModel copyWith({bool? isSelected, int? row, int? col}) {
    return BlockModel(
      number: number,
      row: row ?? this.row,
      col: col ?? this.col,
    )..isSelected = isSelected ?? this.isSelected;
  }

  @override
  String toString() => 'Block($number, r$row, c$col)';
}
