import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/terrace.dart';
import '../bloc/garden/garden_bloc.dart';
import '../bloc/garden/garden_event.dart';
import '../pages/terrace_detail_sheet.dart';

class DraggableTerrace extends StatefulWidget {
  final Terrace terrace;
  final Size canvasSize;

  const DraggableTerrace({
    super.key,
    required this.terrace,
    required this.canvasSize,
  });

  @override
  State<DraggableTerrace> createState() => _DraggableTerraceState();
}

class _DraggableTerraceState extends State<DraggableTerrace> {
  static const double _gridSize = 50;
  static const double _minSize = 50;

  late Offset _position;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _size = _clampSize(Size(widget.terrace.width, widget.terrace.height));
    _position = _clampPosition(
      Offset(widget.terrace.x, widget.terrace.y),
      _size,
    );
  }

  @override
  void didUpdateWidget(covariant DraggableTerrace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.terrace.x != widget.terrace.x ||
        oldWidget.terrace.y != widget.terrace.y) {
      _position = _clampPosition(
        Offset(widget.terrace.x, widget.terrace.y),
        _size,
      );
    }
    if (oldWidget.terrace.width != widget.terrace.width ||
        oldWidget.terrace.height != widget.terrace.height) {
      _size = _clampSize(Size(widget.terrace.width, widget.terrace.height));
      _position = _clampPosition(_position, _size);
    }
    if (oldWidget.canvasSize != widget.canvasSize) {
      _size = _clampSize(_size);
      _position = _clampPosition(_position, _size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = _clampPosition(_position + details.delta, _size);
          });
        },
        onPanEnd: (details) {
          final snappedPosition = _clampPosition(_snapOffset(_position), _size);

          setState(() {
            _position = snappedPosition;
          });

          context.read<GardenBloc>().add(
            UpdateTerracePosition(
              widget.terrace.id,
              snappedPosition.dx,
              snappedPosition.dy,
            ),
          );
        },
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => TerraceDetailSheet(terrace: widget.terrace),
          );
        },
        child: Container(
          width: _size.width,
          height: _size.height,
          decoration: BoxDecoration(
            color: Colors.green.shade400,
            border: Border.all(color: Colors.green.shade900, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${widget.terrace.name}\n${widget.terrace.sunExposure ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      _size = _clampSize(
                        Size(
                          _size.width + details.delta.dx,
                          _size.height + details.delta.dy,
                        ),
                      );
                      _position = _clampPosition(_position, _size);
                    });
                  },
                  onPanEnd: (details) {
                    final snappedSize = _clampSize(_snapSize(_size));

                    setState(() {
                      _size = snappedSize;
                      _position = _clampPosition(_position, _size);
                    });

                    context.read<GardenBloc>().add(
                      UpdateTerraceSize(
                        widget.terrace.id,
                        _size.width,
                        _size.height,
                      ),
                    );
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                    child: const Icon(
                      Icons.open_in_full,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Offset _snapOffset(Offset offset) {
    return Offset(
      (offset.dx / _gridSize).round() * _gridSize,
      (offset.dy / _gridSize).round() * _gridSize,
    );
  }

  Size _snapSize(Size size) {
    return Size(
      (size.width / _gridSize).round() * _gridSize,
      (size.height / _gridSize).round() * _gridSize,
    );
  }

  Offset _clampPosition(Offset position, Size terraceSize) {
    final maxX = (widget.canvasSize.width - terraceSize.width).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (widget.canvasSize.height - terraceSize.height).clamp(
      0.0,
      double.infinity,
    );

    return Offset(
      position.dx.clamp(0.0, maxX).toDouble(),
      position.dy.clamp(0.0, maxY).toDouble(),
    );
  }

  Size _clampSize(Size size) {
    final maxWidth = widget.canvasSize.width.clamp(_minSize, double.infinity);
    final maxHeight = widget.canvasSize.height.clamp(_minSize, double.infinity);

    return Size(
      size.width.clamp(_minSize, maxWidth).toDouble(),
      size.height.clamp(_minSize, maxHeight).toDouble(),
    );
  }
}
