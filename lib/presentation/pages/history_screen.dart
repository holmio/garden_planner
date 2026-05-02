import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garden History')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildYearCard(
            context,
            '2025',
            'Great tomato yield, struggled with carrots due to soil type.',
            120,
          ),
          _buildYearCard(
            context,
            '2024',
            'First year! Planted basic herbs and learned about sun exposure.',
            45,
          ),
        ],
      ),
    );
  }

  Widget _buildYearCard(
    BuildContext context,
    String year,
    String summary,
    int totalCrops,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: ExpansionTile(
        title: Text('Season $year', style: theme.textTheme.titleLarge),
        subtitle: Text('$totalCrops crops harvested'),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Season Notes:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(summary, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('View Photo Diary'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo Diary coming soon!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
