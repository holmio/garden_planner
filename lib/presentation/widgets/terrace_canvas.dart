import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/garden_size.dart';
import '../../domain/entities/terrace.dart';
import '../bloc/terrace/terrace_bloc.dart';
import '../bloc/terrace/terrace_event.dart';
import 'draggable_terrace.dart';
import 'grid_painter.dart';

class TerraceCanvas extends StatefulWidget {
  final List<Terrace> terraces;
  final GardenSize gardenSize;

  const TerraceCanvas({
    super.key,
    required this.terraces,
    required this.gardenSize,
  });

  @override
  State<TerraceCanvas> createState() => _TerraceCanvasState();
}

class _TerraceCanvasState extends State<TerraceCanvas> {
  static const double _minGardenSide = 300;
  static const double _maxGardenSide = 1200;

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
        _fitGardenToViewport(viewportSize);

        return Stack(
          children: [
            InteractiveViewer(
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
                    ...widget.terraces.map(
                      (terrace) => DraggableTerrace(
                        key: ValueKey(terrace.id),
                        terrace: terrace,
                        canvasSize: gardenSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.white.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                elevation: 3,
                child: IconButton(
                  tooltip: 'Garden size',
                  icon: const Icon(Icons.aspect_ratio),
                  color: Colors.brown,
                  onPressed: () => _showGardenSizeSheet(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGardenSizeSheet(BuildContext context) {
    double draftWidth = widget.gardenSize.width;
    double draftHeight = widget.gardenSize.height;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Garden size',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _GardenSizeSlider(
                    label: 'Width',
                    value: draftWidth,
                    min: _minGardenSide,
                    max: _maxGardenSide,
                    onChanged: (value) {
                      draftWidth = value;
                      _updateGardenSize(
                        context,
                        setSheetState,
                        width: draftWidth,
                        height: draftHeight,
                      );
                    },
                  ),
                  _GardenSizeSlider(
                    label: 'Height',
                    value: draftHeight,
                    min: _minGardenSide,
                    max: _maxGardenSide,
                    onChanged: (value) {
                      draftHeight = value;
                      _updateGardenSize(
                        context,
                        setSheetState,
                        width: draftWidth,
                        height: draftHeight,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        draftWidth = _defaultGardenSize.width;
                        draftHeight = _defaultGardenSize.height;
                        _updateGardenSize(
                          context,
                          setSheetState,
                          width: draftWidth,
                          height: draftHeight,
                        );
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateGardenSize(
    BuildContext context,
    StateSetter setSheetState, {
    double? width,
    double? height,
  }) {
    final updatedSize = GardenSize(
      width: (width ?? widget.gardenSize.width)
          .clamp(_minGardenSide, _maxGardenSide)
          .toDouble(),
      height: (height ?? widget.gardenSize.height)
          .clamp(_minGardenSide, _maxGardenSide)
          .toDouble(),
    );

    setState(() {
      _lastViewportSize = null;
      _lastGardenSize = null;
    });
    setSheetState(() {});

    context.read<TerraceBloc>().add(
      UpdateGardenSize(updatedSize.width, updatedSize.height),
    );
  }

  void _fitGardenToViewport(Size viewportSize) {
    final gardenSize = _canvasSize;
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
      Size(widget.gardenSize.width, widget.gardenSize.height);

  GardenSize get _defaultGardenSize => GardenSize.defaultSize;
}

class _GardenSizeSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _GardenSizeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 20).round(),
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(value.round().toString(), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
