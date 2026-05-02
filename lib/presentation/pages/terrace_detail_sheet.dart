import 'package:flutter/material.dart';
import '../../../domain/entities/terrace.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';
import 'plant_search_screen.dart';

class TerraceDetailSheet extends StatefulWidget {
  final Terrace terrace;

  const TerraceDetailSheet({super.key, required this.terrace});

  @override
  State<TerraceDetailSheet> createState() => _TerraceDetailSheetState();
}

class _TerraceDetailSheetState extends State<TerraceDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appTheme = theme.extension<AppThemeExtension>()!;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: appTheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.terrace.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildFeatureIcon(
                  context,
                  Icons.wb_sunny,
                  widget.terrace.sunExposure ?? 'Unknown Sun',
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFeatureIcon(
                  context,
                  Icons.water_drop,
                  widget.terrace.irrigationType ?? 'No Irrigation',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Current Crops', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.error,
                child: Icon(Icons.local_florist, color: colors.onError),
              ),
              title: const Text('Tomatoes'),
              subtitle: const Text('Harvest in 20 days'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Plant a new Crop'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                ),
                onPressed: () async {
                  final selectedPlant = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlantSearchScreen(),
                    ),
                  );
                  if (selectedPlant != null) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully planted $selectedPlant!'),
                        backgroundColor: appTheme.successText,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    final appTheme = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: appTheme.gardenGrid, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: appTheme.gardenBorder),
        ),
      ],
    );
  }
}
