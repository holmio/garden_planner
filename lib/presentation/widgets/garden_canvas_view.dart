import 'package:flutter/material.dart';

import '../../domain/entities/garden.dart';
import 'draggable_terrace.dart';
import 'grid_painter.dart';

class GardenCanvasView extends StatefulWidget {
  final Garden garden;

  const GardenCanvasView({super.key, required this.garden});

  @override
  State<GardenCanvasView> createState() => _GardenCanvasViewState();
}

class _GardenCanvasViewState extends State<GardenCanvasView> {
  final TransformationController _transformationController =
      TransformationController();

  Size? _lastViewportSize;
  Size? _lastGardenSize;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final gardenSize = _canvasSize;
        _fitGardenToViewport(viewportSize, gardenSize);

        return InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          minScale: 0.5,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(120),
          child: Container(
            width: gardenSize.width,
            height: gardenSize.height,
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              border: Border.all(color: Colors.brown.shade800, width: 4),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: GridPainter())),
                ...widget.garden.terraces.map(
                  (terrace) => DraggableTerrace(
                    key: ValueKey(terrace.id),
                    terrace: terrace,
                    canvasSize: gardenSize,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fitGardenToViewport(Size viewportSize, Size gardenSize) {
    if (_lastViewportSize == viewportSize && _lastGardenSize == gardenSize) {
      return;
    }
    _lastViewportSize = viewportSize;
    _lastGardenSize = gardenSize;

    final scaleX = viewportSize.width / gardenSize.width;
    final scaleY = viewportSize.height / gardenSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final fittedScale = scale.clamp(0.5, 1.0).toDouble();
    final left = (viewportSize.width - gardenSize.width * fittedScale) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(left, 0.0)
      ..scale(fittedScale);
  }

  Size get _canvasSize =>
      Size(widget.garden.size.width, widget.garden.size.height);
}
