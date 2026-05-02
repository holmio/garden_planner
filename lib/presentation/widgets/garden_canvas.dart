import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme_extension.dart';
import '../../domain/entities/garden.dart';
import '../../domain/entities/garden_size.dart';
import '../bloc/garden/garden_bloc.dart';
import '../bloc/garden/garden_event.dart';
import 'garden_canvas_view.dart';
import 'garden_size_sheet.dart';

class GardenCanvas extends StatelessWidget {
  final Garden garden;

  const GardenCanvas({super.key, required this.garden});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>()!;

    return Stack(
      children: [
        GardenCanvasView(garden: garden),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            shape: const CircleBorder(),
            elevation: 3,
            child: IconButton(
              tooltip: 'Garden size',
              icon: const Icon(Icons.aspect_ratio),
              color: appTheme.gardenBorder,
              onPressed: () => _showGardenSizeSheet(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showGardenSizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => GardenSizeSheet(
        gardenSize: garden.size,
        onChanged: (size) => _updateGardenSize(context, size),
      ),
    );
  }

  void _updateGardenSize(BuildContext context, GardenSize size) {
    context.read<GardenBloc>().add(UpdateGardenSize(size.width, size.height));
  }
}
