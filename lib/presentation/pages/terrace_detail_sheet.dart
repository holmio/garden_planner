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
        final terrace = _currentTerrace(state);

        return _buildSheet(context, terrace);
      },
    );
  }

  Terrace _currentTerrace(GardenState state) {
    if (state is! GardenLoaded) return widget.terrace;

    for (final terrace in state.garden.terraces) {
      if (terrace.id == widget.terrace.id) return terrace;
    }

    return widget.terrace;
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
                subtitle: Text(_cropSubtitle(terrace)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openCurrentPlant(context, terrace),
              ),
            if (terrace.plantName != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Lifecycle', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _LifecycleDateTile(
                icon: Icons.event_available,
                label: 'Planted',
                value: _formatDate(terrace.plantingDate),
                onTap: () =>
                    _pickLifecycleDate(context, terrace, isPlantingDate: true),
              ),
              _LifecycleDateTile(
                icon: Icons.agriculture,
                label: 'Expected harvest',
                value: _formatDate(terrace.expectedHarvestDate),
                onTap: () =>
                    _pickLifecycleDate(context, terrace, isPlantingDate: false),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Harvest reminder'),
                subtitle: Text(
                  terrace.expectedHarvestDate == null
                      ? 'Set a harvest date first'
                      : terrace.harvestReminderEnabled
                      ? 'Reminder enabled'
                      : 'Reminder off',
                ),
                value: terrace.harvestReminderEnabled,
                onChanged: terrace.expectedHarvestDate == null
                    ? null
                    : (enabled) => context.read<GardenBloc>().add(
                        UpdateTerraceLifecycle(
                          id: terrace.id,
                          harvestReminderEnabled: enabled,
                        ),
                      ),
              ),
            ],
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
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Terrace'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                ),
                onPressed: () => _confirmRemoveTerrace(context, terrace),
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
    final plantingDate = _dateOnly(DateTime.now());
    final daysToHarvest = _intFromValue(selectedPlant['days_to_harvest']);
    final expectedHarvestDate = daysToHarvest == null
        ? null
        : plantingDate.add(Duration(days: daysToHarvest));
    context.read<GardenBloc>().add(
      UpdateTerracePlant(
        id: terrace.id,
        plantName: plantName,
        plantDescription: selectedPlant['description']?.toString(),
        plantImagePath: selectedPlant['main_image_path']?.toString(),
        plantDetailPath: selectedPlant['plant_detail_path']?.toString(),
        plantingDate: plantingDate,
        expectedHarvestDate: expectedHarvestDate,
        harvestReminderEnabled: expectedHarvestDate != null,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully planted $plantName.'),
        backgroundColor: appTheme.successText,
      ),
    );
  }

  Future<void> _confirmRemoveTerrace(
    BuildContext context,
    Terrace terrace,
  ) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove terrace?'),
          content: Text(
            'Remove ${terrace.name} and its crop details from this garden?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );

    if (!context.mounted || shouldRemove != true) return;

    context.read<GardenBloc>().add(RemoveTerrace(terrace.id));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${terrace.name} removed. Save to keep changes.')),
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

  Future<void> _pickLifecycleDate(
    BuildContext context,
    Terrace terrace, {
    required bool isPlantingDate,
  }) async {
    final now = _dateOnly(DateTime.now());
    final initialDate =
        (isPlantingDate ? terrace.plantingDate : terrace.expectedHarvestDate) ??
        now;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (!context.mounted || selectedDate == null) return;

    context.read<GardenBloc>().add(
      UpdateTerraceLifecycle(
        id: terrace.id,
        plantingDate: isPlantingDate ? _dateOnly(selectedDate) : null,
        expectedHarvestDate: isPlantingDate ? null : _dateOnly(selectedDate),
        updatePlantingDate: isPlantingDate,
        updateExpectedHarvestDate: !isPlantingDate,
      ),
    );
  }

  String _cropSubtitle(Terrace terrace) {
    final harvestDate = terrace.expectedHarvestDate;
    if (harvestDate != null) {
      return 'Harvest around ${_formatDate(harvestDate)}';
    }

    return terrace.plantDescription ?? 'Planted here';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';

    return '${date.month}/${date.day}/${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int? _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);

    return null;
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

class _LifecycleDateTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LifecycleDateTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onTap,
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
