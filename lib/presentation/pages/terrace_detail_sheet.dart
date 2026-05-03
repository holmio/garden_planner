import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/terrace.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';
import '../bloc/garden/garden_bloc.dart';
import '../bloc/garden/garden_event.dart';
import '../bloc/garden/garden_state.dart';
import 'plant_search_screen.dart';

class TerraceDetailSheet extends StatefulWidget {
  final Terrace terrace;

  const TerraceDetailSheet({super.key, required this.terrace});

  @override
  State<TerraceDetailSheet> createState() => _TerraceDetailSheetState();
}

class _TerraceDetailSheetState extends State<TerraceDetailSheet> {
  static const List<String> _sunOptions = ['Full sun', 'Partial sun', 'Shade'];
  static const List<String> _irrigationOptions = [
    'Manual',
    'Drip',
    'Sprinkler',
    'Rain only',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GardenBloc, GardenState>(
      builder: (context, state) {
        final terrace = state is GardenLoaded
            ? state.garden.terraces.firstWhere(
                (terrace) => terrace.id == widget.terrace.id,
                orElse: () => widget.terrace,
              )
            : widget.terrace;

        return _buildSheet(context, terrace);
      },
    );
  }

  Widget _buildSheet(BuildContext context, Terrace terrace) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appTheme = theme.extension<AppThemeExtension>()!;
    final displayName = terrace.plantName ?? terrace.name;

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
                    displayName,
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
                  terrace.sunExposure ?? 'Sun not set',
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFeatureIcon(
                  context,
                  Icons.water_drop,
                  terrace.irrigationType ?? 'Irrigation not set',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Sun', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: _sunOptions.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: terrace.sunExposure == option,
                  onSelected: (_) => context.read<GardenBloc>().add(
                    UpdateTerraceSunExposure(terrace.id, option),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Irrigation', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: _irrigationOptions.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: terrace.irrigationType == option,
                  onSelected: (_) => context.read<GardenBloc>().add(
                    UpdateTerraceIrrigationType(terrace.id, option),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Current Crops', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            if (terrace.plantName == null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    Icons.local_florist,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                title: const Text('No plant selected'),
                subtitle: const Text('Choose one crop for this terrace'),
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _PlantAvatar(terrace: terrace),
                title: Text(terrace.plantName!),
                subtitle: Text(terrace.plantDescription ?? 'Planted here'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openCurrentPlant(context, terrace),
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(
                  terrace.plantName == null ? 'Plant a Crop' : 'Change Crop',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                ),
                onPressed: () => _selectPlant(context, terrace, appTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPlant(
    BuildContext context,
    Terrace terrace,
    AppThemeExtension appTheme,
  ) async {
    final selectedPlant = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const PlantSearchScreen()),
    );
    if (!context.mounted || selectedPlant == null) return;

    final plantName = selectedPlant['name']?.toString() ?? 'Unknown Plant';
    context.read<GardenBloc>().add(
      UpdateTerracePlant(
        id: terrace.id,
        plantName: plantName,
        plantDescription: selectedPlant['description']?.toString(),
        plantImagePath: selectedPlant['main_image_path']?.toString(),
        plantDetailPath: selectedPlant['plant_detail_path']?.toString(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully planted $plantName.'),
        backgroundColor: appTheme.successText,
      ),
    );
  }

  void _openCurrentPlant(BuildContext context, Terrace terrace) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDetailScreen(
          plant: {
            'name': terrace.plantName,
            'description': terrace.plantDescription,
            'main_image_path': terrace.plantImagePath,
            'plant_detail_path': terrace.plantDetailPath,
          },
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

class _PlantAvatar extends StatelessWidget {
  final Terrace terrace;

  const _PlantAvatar({required this.terrace});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imagePath = terrace.plantImagePath;

    if (imagePath != null && imagePath.startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(imagePath));
    }

    return CircleAvatar(
      backgroundColor: colors.primaryContainer,
      child: Icon(Icons.local_florist, color: colors.onPrimaryContainer),
    );
  }
}
