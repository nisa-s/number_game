// lib/widgets/game_grid.dart
// Kişi 2 – Düşme Mekaniği sorumluluğu
//
// 8x10 grid widget'ı. Hem yerleşik blokları hem de
// anlık düşen bloğu çizer.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/block_model.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().state;

    return AspectRatio(
      // 8 sütun / 10 satır oranı
      aspectRatio: kGridCols / kGridRows,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          border: Border.all(color: const Color(0xFF4A4A6A), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kGridCols,
            childAspectRatio: 1,
          ),
          itemCount: kGridRows * kGridCols,
          itemBuilder: (context, index) {
            final row = index ~/ kGridCols;
            final col = index % kGridCols;
            final block = _resolveCell(state, row, col);
            return _GridCell(block: block, row: row, col: col);
          },
        ),
      ),
    );
  }

  /// Hücrede ne gösterilmeli?
  /// Önce düşen blok kontrolü, sonra grid'deki sabit blok.
  BlockModel? _resolveCell(GameState state, int row, int col) {
    // Düşen blok bu hücrede mi?
    if (state.fallingBlock != null &&
        state.fallingRow == row &&
        state.fallingCol == col) {
      return state.fallingBlock;
    }
    return state.grid[row][col];
  }
}

class _GridCell extends StatelessWidget {
  final BlockModel? block;
  final int row;
  final int col;

  const _GridCell({required this.block, required this.row, required this.col});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: block != null
          ? () => context.read<GameProvider>().selectBlock(row, col)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: block != null ? block!.color : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: block?.isSelected == true
                ? Colors.white
                : const Color(0xFF2A2A4A),
            width: block?.isSelected == true ? 2.5 : 1,
          ),
          boxShadow: block != null
              ? [
                  BoxShadow(
                    color: block!.color.withValues(alpha:0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: block != null
            ? Center(
                child: Text(
                  '${block!.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}