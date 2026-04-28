import 'package:flutter/material.dart';
import '../../data/datasources/plant_api_service.dart';

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

  void _search() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await _apiService.searchPlants(_searchController.text);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Plant Database'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.green)))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final plant = _results[index];
                  return ListTile(
                    leading: plant['main_image_path'] != null && plant['main_image_path'].toString().startsWith('http')
                        ? Image.network(plant['main_image_path'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_florist, color: Colors.green))
                        : const Icon(Icons.local_florist, color: Colors.green),
                    title: Text(plant['name'] ?? 'Unknown Plant', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(plant['description'] ?? 'No description available.', maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.add_circle, color: Colors.green),
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
