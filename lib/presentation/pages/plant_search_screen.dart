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
                    trailing: Icon(Icons.add_circle, color: colors.primary),
                    onTap: () {
                      Navigator.pop(context, plant['name']);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
