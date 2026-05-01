import 'package:flutter/material.dart';

import '../../domain/entities/terrace.dart';
import 'draggable_terrace.dart';
import 'grid_painter.dart';

class TerraceCanvas extends StatelessWidget {
  final List<Terrace> terraces;

  const TerraceCanvas({super.key, required this.terraces});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 4.0,
      constrained: false,
      child: Container(
        width: 2000,
        height: 2000,
        decoration: BoxDecoration(
          color: Colors.brown.shade200,
          border: Border.all(color: Colors.brown.shade800, width: 4),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: GridPainter())),
            ...terraces.map(
              (terrace) =>
                  DraggableTerrace(key: ValueKey(terrace.id), terrace: terrace),
            ),
          ],
        ),
      ),
    );
  }
}
