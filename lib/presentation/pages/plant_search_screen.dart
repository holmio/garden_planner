import 'package:flutter/material.dart';
import '../../data/datasources/plant_api_service.dart';
import '../../core/theme/app_spacing.dart';

class PlantSearchScreen extends StatefulWidget {
  const PlantSearchScreen({super.key});

  @override
  State<PlantSearchScreen> createState() => _PlantSearchScreenState();
}

class _PlantSearchScreenState extends State<PlantSearchScreen> {
  final PlantApiService _apiService = PlantApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final results = await _apiService.searchPlants(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } on PlantApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openPlantDetails(Map<String, dynamic> plant) async {
    final selectedPlant = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => PlantDetailScreen(plant: plant)),
    );

    if (!mounted || selectedPlant == null) return;
    Navigator.pop(context, selectedPlant);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search Plant Database')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Tomato, Basil, Carrot...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  child: Icon(Icons.search, color: colors.onPrimary),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ),
            )
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Search for edible garden plants to add to this terrace.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final plant = _results[index];
                  return ListTile(
                    leading:
                        plant['main_image_path'] != null &&
                            plant['main_image_path'].toString().startsWith(
                              'http',
                            )
                        ? Image.network(
                            plant['main_image_path'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.local_florist,
                              color: colors.primary,
                            ),
                          )
                        : Icon(Icons.local_florist, color: colors.primary),
                    title: Text(
                      plant['name'] ?? 'Unknown Plant',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      plant['description'] ?? 'No description available.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(Icons.chevron_right, color: colors.primary),
                    onTap: () => _openPlantDetails(plant),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final PlantApiService _apiService = PlantApiService();
  Map<String, dynamic>? _details;
  bool _isLoadingDetails = false;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final detailPath = widget.plant['plant_detail_path']?.toString();
    if (detailPath == null || detailPath.isEmpty) return;

    setState(() => _isLoadingDetails = true);
    try {
      final details = await _apiService.fetchPlantDetails(detailPath);
      if (!mounted) return;
      setState(() {
        _details = details;
        _isLoadingDetails = false;
      });
    } on PlantApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _detailError = error.message;
        _isLoadingDetails = false;
      });
    }
  }

  Map<String, dynamic> get _plant {
    final merged = Map<String, dynamic>.of(widget.plant);
    for (final entry in (_details ?? {}).entries) {
      if (entry.value != null) merged[entry.key] = entry.value;
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final plant = _plant;
    final plantName = plant['name']?.toString() ?? 'Unknown Plant';
    final imagePath = plant['main_image_path']?.toString();
    final synonyms = plant['synonyms'];

    return Scaffold(
      appBar: AppBar(title: Text(plantName)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (imagePath != null && imagePath.startsWith('http'))
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagePath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _PlantImageError(color: colors.primary),
              ),
            )
          else
            _PlantImageError(color: colors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(plantName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          if (_isLoadingDetails) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
          ] else if (_detailError != null) ...[
            Text(
              _detailError!,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _PlantInfoSection(
            label: 'Gardening notes',
            value: plant['observations'],
          ),
          _PlantInfoGroup(
            title: 'Growing',
            rows: [
              _PlantInfoItem('Duration', plant['duration']),
              _PlantInfoItem('Growth habit', plant['growth_habit']),
              _PlantInfoItem('Growth form', plant['growth_form']),
              _PlantInfoItem('Growth rate', plant['growth_rate']),
              _PlantInfoItem('Days to harvest', plant['days_to_harvest']),
              _PlantInfoItem('Sowing', plant['sowing']),
              _PlantInfoItem('Active growth months', plant['growth_months']),
              _PlantInfoItem('Bloom months', plant['bloom_months']),
              _PlantInfoItem('Fruit months', plant['fruit_months']),
            ],
          ),
          _PlantInfoGroup(
            title: 'Garden Conditions',
            rows: [
              _PlantInfoItem('Light', _scaleValue(plant['light'])),
              _PlantInfoItem(
                'Soil moisture',
                _scaleValue(plant['soil_humidity']),
              ),
              _PlantInfoItem(
                'Soil texture',
                _scaleValue(plant['soil_texture']),
              ),
              _PlantInfoItem(
                'Soil nutrients',
                _scaleValue(plant['soil_nutriments']),
              ),
              _PlantInfoItem('Soil pH', _phRange(plant)),
              _PlantInfoItem(
                'Minimum temperature',
                plant['minimum_temperature'],
              ),
              _PlantInfoItem(
                'Maximum temperature',
                plant['maximum_temperature'],
              ),
              _PlantInfoItem('Root depth', plant['minimum_root_depth']),
            ],
          ),
          _PlantInfoGroup(
            title: 'Spacing and Size',
            rows: [
              _PlantInfoItem('Row spacing', plant['row_spacing']),
              _PlantInfoItem('Spread', plant['spread']),
              _PlantInfoItem('Average height', plant['average_height']),
              _PlantInfoItem('Maximum height', plant['maximum_height']),
            ],
          ),
          _PlantInfoGroup(
            title: 'Food and Safety',
            rows: [
              _PlantInfoItem('Edible', _yesNo(plant['edible'])),
              _PlantInfoItem('Vegetable', _yesNo(plant['vegetable'])),
              _PlantInfoItem('Edible parts', plant['edible_part']),
              _PlantInfoItem('Toxicity', plant['toxicity']),
            ],
          ),
          _PlantInfoGroup(
            title: 'Plant Features',
            rows: [
              _PlantInfoItem('Flower color', plant['flower_color']),
              _PlantInfoItem('Foliage color', plant['foliage_color']),
              _PlantInfoItem('Foliage texture', plant['foliage_texture']),
              _PlantInfoItem('Fruit color', plant['fruit_color']),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PlantInfoRow(
            label: 'Scientific name',
            value: plant['scientific_name'],
          ),
          _PlantInfoRow(label: 'Common name', value: plant['common_name']),
          _PlantInfoRow(label: 'Family', value: plant['family_common_name']),
          _PlantInfoRow(label: 'Botanical family', value: plant['family']),
          _PlantInfoRow(label: 'Genus', value: plant['genus']),
          _PlantInfoRow(label: 'Status', value: plant['status']),
          _PlantInfoRow(label: 'First described', value: plant['year']),
          if (synonyms is List && synonyms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Also known as', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              synonyms.take(5).join(', '),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          _PlantInfoSection(label: 'Source', value: plant['bibliography']),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Plant this'),
            onPressed: () => Navigator.pop(context, plant),
          ),
        ),
      ),
    );
  }

  String? _yesNo(Object? value) {
    if (value is bool) return value ? 'Yes' : 'No';
    return null;
  }

  String? _scaleValue(Object? value) {
    if (value == null) return null;
    return '$value / 10';
  }

  String? _phRange(Map<String, dynamic> plant) {
    final minimum = plant['ph_minimum'];
    final maximum = plant['ph_maximum'];
    if (minimum == null && maximum == null) return null;
    if (minimum == null) return 'Up to $maximum';
    if (maximum == null) return 'From $minimum';
    return '$minimum - $maximum';
  }
}

class _PlantInfoItem {
  final String label;
  final Object? value;

  const _PlantInfoItem(this.label, this.value);
}

class _PlantInfoGroup extends StatelessWidget {
  final String title;
  final List<_PlantInfoItem> rows;

  const _PlantInfoGroup({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final visibleRows = rows.where((row) => _formatValue(row.value) != null);
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...visibleRows.map(
            (row) => _PlantInfoRow(label: row.label, value: row.value),
          ),
        ],
      ),
    );
  }
}

class _PlantImageError extends StatelessWidget {
  final Color color;

  const _PlantImageError({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.08),
      ),
      child: Icon(Icons.local_florist, color: color, size: 56),
    );
  }
}

class _PlantInfoRow extends StatelessWidget {
  final String label;
  final Object? value;

  const _PlantInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textValue = _formatValue(value);
    if (textValue == null || textValue.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(child: Text(textValue, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _PlantInfoSection extends StatelessWidget {
  final String label;
  final Object? value;

  const _PlantInfoSection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textValue = _formatValue(value);
    if (textValue == null || textValue.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(textValue, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String? _formatValue(Object? value) {
  if (value == null) return null;
  if (value is Iterable) {
    final items = value
        .map((item) {
          if (item is Map && item['name'] != null) return item['name'];
          return item;
        })
        .where((item) => item != null && item.toString().isNotEmpty)
        .map((item) => item.toString())
        .toList();
    return items.isEmpty ? null : items.join(', ');
  }
  final textValue = value.toString();
  return textValue.isEmpty ? null : textValue;
}
