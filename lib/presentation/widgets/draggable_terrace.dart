import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/terrace.dart';
import '../bloc/terrace/terrace_bloc.dart';
import '../bloc/terrace/terrace_event.dart';
import '../pages/terrace_detail_sheet.dart';

class DraggableTerrace extends StatefulWidget {
  final Terrace terrace;

  const DraggableTerrace({super.key, required this.terrace});

  @override
  State<DraggableTerrace> createState() => _DraggableTerraceState();
}

class _DraggableTerraceState extends State<DraggableTerrace> {
  static const double _gridSize = 50;
  static const double _minSize = 50;
  static const double _maxSize = 600;

  late Offset _position;
  late Size _size;

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.terrace.x, widget.terrace.y);
    _size = Size(widget.terrace.width, widget.terrace.height);
  }

  @override
  void didUpdateWidget(covariant DraggableTerrace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.terrace.x != widget.terrace.x ||
        oldWidget.terrace.y != widget.terrace.y) {
      _position = Offset(widget.terrace.x, widget.terrace.y);
    }
    if (oldWidget.terrace.width != widget.terrace.width ||
        oldWidget.terrace.height != widget.terrace.height) {
      _size = Size(widget.terrace.width, widget.terrace.height);
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
            _position += details.delta;
          });
        },
        onPanEnd: (details) {
          final snappedPosition = Offset(
            (_position.dx / _gridSize).round() * _gridSize,
            (_position.dy / _gridSize).round() * _gridSize,
          );

          setState(() {
            _position = snappedPosition;
          });

          context.read<TerraceBloc>().add(
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
                      _size = Size(
                        (_size.width + details.delta.dx).clamp(
                          _minSize,
                          _maxSize,
                        ),
                        (_size.height + details.delta.dy).clamp(
                          _minSize,
                          _maxSize,
                        ),
                      );
                    });
                  },
                  onPanEnd: (details) {
                    final snappedSize = Size(
                      (_size.width / _gridSize).round() * _gridSize,
                      (_size.height / _gridSize).round() * _gridSize,
                    );

                    setState(() {
                      _size = Size(
                        snappedSize.width.clamp(_minSize, _maxSize),
                        snappedSize.height.clamp(_minSize, _maxSize),
                      );
                    });

                    context.read<TerraceBloc>().add(
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
}
