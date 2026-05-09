import 'dart:convert';

import 'package:flutter/services.dart';

class PlantApiException implements Exception {
  final String message;

  const PlantApiException(this.message);

  @override
  String toString() => message;
}

class PlantApiService {
  static const String _catalogAssetPath =
      'assets/data/common_plants_europe.json';

  final AssetBundle _assetBundle;
  final List<Map<String, dynamic>>? _plants;

  PlantApiService({
    AssetBundle? assetBundle,
    List<Map<String, dynamic>>? plants,
  }) : _assetBundle = assetBundle ?? rootBundle,
       _plants = plants;

  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final plants = await _loadPlants();
    final normalizedQuery = _normalize(trimmedQuery);
    final matches = plants.where((plant) {
      final searchableValues = [
        plant['id'],
        plant['name'],
        plant['common_name'],
        plant['scientific_name'],
        plant['family'],
        plant['family_common_name'],
        plant['genus'],
        ..._asStringList(plant['aliases']),
        ..._asStringList(plant['tags']),
      ];

      return searchableValues.any(
        (value) =>
            _normalize(value?.toString() ?? '').contains(normalizedQuery),
      );
    }).toList();

    return matches.map(_toSearchRecord).toList();
  }

  Future<Map<String, dynamic>> fetchPlantDetails(String path) async {
    final plantId = path.startsWith('catalog://')
        ? path.substring('catalog://'.length)
        : path;
    final plants = await _loadPlants();
    for (final plant in plants) {
      if (plant['id'] == plantId) return _toDetailRecord(plant);
    }

    throw const PlantApiException(
      'This plant is not in the local catalog yet.',
    );
  }

  Future<List<Map<String, dynamic>>> _loadPlants() async {
    if (_plants != null) return _plants;

    try {
      final contents = await _assetBundle.loadString(_catalogAssetPath);
      final decoded = json.decode(contents);
      if (decoded is! Map<String, dynamic> || decoded['plants'] is! List) {
        throw const PlantApiException(
          'The local plant catalog is not in the expected format.',
        );
      }

      return (decoded['plants'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (error) {
      if (error is PlantApiException) rethrow;
      throw const PlantApiException('Could not load the local plant catalog.');
    }
  }

  Map<String, dynamic> _toSearchRecord(Map<String, dynamic> plant) {
    return {
      'name': plant['name'],
      'description': plant['description'],
      'main_image_path': plant['icon_asset_path'],
      'icon_asset_path': plant['icon_asset_path'],
      'common_name': plant['common_name'],
      'scientific_name': plant['scientific_name'],
      'family': plant['family'],
      'family_common_name': plant['family_common_name'],
      'genus': plant['genus'],
      'status': 'Curated garden crop',
      'year': null,
      'bibliography': plant['source_note'],
      'synonyms': plant['aliases'],
      'duration': plant['duration'],
      'edible': true,
      'vegetable': plant['category'] != 'fruit' && plant['category'] != 'herb',
      'edible_part': plant['edible_parts'],
      'observations': plant['observations'],
      'days_to_harvest': plant['days_to_harvest'],
      'plant_detail_path': 'catalog://${plant['id']}',
    };
  }

  Map<String, dynamic> _toDetailRecord(Map<String, dynamic> plant) {
    final spacing = _asMap(plant['spacing']);
    final height = _asMap(plant['height_cm']);
    final soil = _asMap(plant['soil']);
    final seasons = _asMap(plant['europe_season']);
    final companions = _asMap(plant['companions']);
    final problems = _asMap(plant['problems']);
    final care = _asMap(plant['care']);
    final rotation = _asMap(plant['rotation']);

    return {
      ..._toSearchRecord(plant),
      'duration': plant['duration'],
      'growth_habit': plant['plant_type'],
      'growth_form': plant['category'],
      'growth_rate': plant['growth_rate'],
      'sowing': _formatSeason(seasons?['sow_or_plant']),
      'growth_months': seasons?['main_growth'],
      'bloom_months': seasons?['flowering'],
      'fruit_months': seasons?['harvest'],
      'light': plant['light'],
      'soil_humidity': plant['soil_moisture'],
      'soil_texture': soil?['texture'],
      'soil_nutriments': soil?['nutrients'],
      'ph_minimum': soil?['ph_min'],
      'ph_maximum': soil?['ph_max'],
      'minimum_temperature': plant['minimum_temperature'],
      'maximum_temperature': plant['maximum_temperature'],
      'minimum_root_depth': plant['minimum_root_depth'],
      'row_spacing': _formatCm(spacing?['between_rows_cm']),
      'spread': _formatCm(spacing?['between_plants_cm']),
      'average_height': _formatHeight(height, average: true),
      'maximum_height': _formatHeight(height),
      'toxicity': plant['toxicity'],
      'flower_color': plant['flower_color'],
      'foliage_color': plant['foliage_color'],
      'fruit_color': plant['fruit_color'],
      'difficulty': plant['difficulty'],
      'planting_depth': _formatCm(spacing?['planting_depth_cm']),
      'good_companions': companions?['good'],
      'bad_companions': companions?['bad'],
      'watering': care?['watering'],
      'fertilizing': care?['fertilizing'],
      'care_notes': care?['notes'],
      'pests': problems?['pests'],
      'diseases': problems?['diseases'],
      'warnings': problems?['warnings'],
      'rotation_family': rotation?['family'],
      'avoid_same_bed_years': rotation?['avoid_same_bed_years'],
      'rotation_notes': rotation?['notes'],
      'tags': plant['tags'],
    };
  }

  Map<String, dynamic>? _asMap(Object? value) {
    return value is Map<String, dynamic> ? value : null;
  }

  List<String> _asStringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  String? _formatSeason(Object? value) {
    if (value is! List || value.isEmpty) return null;
    return value.join(', ');
  }

  String? _formatCm(Object? value) {
    if (value == null) return null;
    return '$value cm';
  }

  String? _formatHeight(Map<String, dynamic>? height, {bool average = false}) {
    if (height == null) return null;
    final min = height['min'];
    final max = height['max'];
    if (average && min is num && max is num) {
      return '${((min + max) / 2).round()} cm';
    }
    return _formatCm(max ?? min);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
