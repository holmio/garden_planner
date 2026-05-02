import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../domain/entities/garden_size.dart';

class GardenSizeSheet extends StatefulWidget {
  static const double minGardenSide = 300;
  static const double maxGardenSide = 1200;

  final GardenSize gardenSize;
  final ValueChanged<GardenSize> onChanged;

  const GardenSizeSheet({
    super.key,
    required this.gardenSize,
    required this.onChanged,
  });

  @override
  State<GardenSizeSheet> createState() => _GardenSizeSheetState();
}

class _GardenSizeSheetState extends State<GardenSizeSheet> {
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _width = widget.gardenSize.width;
    _height = widget.gardenSize.height;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Garden size', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          _GardenSizeSlider(
            label: 'Width',
            value: _width,
            onChanged: (value) => _updateSize(width: value),
          ),
          _GardenSizeSlider(
            label: 'Height',
            value: _height,
            onChanged: (value) => _updateSize(height: value),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _updateSize(
                width: GardenSize.defaultSize.width,
                height: GardenSize.defaultSize.height,
              ),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSize({double? width, double? height}) {
    setState(() {
      _width = (width ?? _width)
          .clamp(GardenSizeSheet.minGardenSide, GardenSizeSheet.maxGardenSide)
          .toDouble();
      _height = (height ?? _height)
          .clamp(GardenSizeSheet.minGardenSide, GardenSizeSheet.maxGardenSide)
          .toDouble();
    });

    widget.onChanged(GardenSize(width: _width, height: _height));
  }
}

class _GardenSizeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _GardenSizeSlider({
    required this.label,
    required this.value,
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: GardenSizeSheet.minGardenSide,
            max: GardenSizeSheet.maxGardenSide,
            divisions:
                ((GardenSizeSheet.maxGardenSide -
                            GardenSizeSheet.minGardenSide) /
                        20)
                    .round(),
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
