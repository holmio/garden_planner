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
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = Offset(widget.terrace.x, widget.terrace.y);
  }

  @override
  void didUpdateWidget(covariant DraggableTerrace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.terrace.x != widget.terrace.x ||
        oldWidget.terrace.y != widget.terrace.y) {
      _position = Offset(widget.terrace.x, widget.terrace.y);
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
            (_position.dx / 50).round() * 50.0,
            (_position.dy / 50).round() * 50.0,
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
          width: widget.terrace.width,
          height: widget.terrace.height,
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
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 12,
                    color: Colors.black,
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
