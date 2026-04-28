import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden History'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildYearCard(context, '2025', 'Great tomato yield, struggled with carrots due to soil type.', 120),
          _buildYearCard(context, '2024', 'First year! Planted basic herbs and learned about sun exposure.', 45),
        ],
      ),
    );
  }

  Widget _buildYearCard(BuildContext context, String year, String summary, int totalCrops) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          'Season $year',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        subtitle: Text('$totalCrops crops harvested'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Season Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(summary, style: TextStyle(color: Colors.grey.shade800)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('View Photo Diary'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Photo Diary coming soon!')),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
