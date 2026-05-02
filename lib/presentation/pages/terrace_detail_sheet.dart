import 'package:flutter/material.dart';
import '../../../domain/entities/terrace.dart';
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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFeatureIcon(
                  Icons.wb_sunny,
                  widget.terrace.sunExposure ?? 'Unknown Sun',
                ),
                const SizedBox(width: 16),
                _buildFeatureIcon(
                  Icons.water_drop,
                  widget.terrace.irrigationType ?? 'No Irrigation',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Current Crops',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.local_florist, color: Colors.white),
              ),
              title: const Text('Tomatoes'),
              subtitle: const Text('Harvest in 20 days'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Plant a new Crop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                        backgroundColor: Colors.green.shade700,
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

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.brown.shade400, size: 20),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.brown.shade700)),
      ],
    );
  }
}
