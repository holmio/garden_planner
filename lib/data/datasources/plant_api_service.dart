import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlantApiException implements Exception {
  final String message;

  const PlantApiException(this.message);

  @override
  String toString() => message;
}

class PlantApiService {
  static const String _baseUrl = 'https://trefle.io';
  static const String _searchPath = '/api/v1/plants/search';

  final http.Client _client;
  final String? _apiToken;

  PlantApiService({http.Client? client, String? apiToken})
    : _client = client ?? http.Client(),
      _apiToken = apiToken ?? dotenv.env['TREFLE_API_TOKEN'];

  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];
    final token = _apiToken?.trim();
    if (token == null || token.isEmpty) {
      throw const PlantApiException(
        'Missing Trefle API token. Add TREFLE_API_TOKEN to your .env file.',
      );
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl$_searchPath',
      ).replace(queryParameters: {'token': token, 'q': trimmedQuery});
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          throw const PlantApiException(
            'The plant database is not returning JSON right now.',
          );
        }

        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
          throw const PlantApiException(
            'The plant database response was not in the expected format.',
          );
        }

        final records = decoded['data'] as List<dynamic>;
        return records
            .whereType<Map<String, dynamic>>()
            .map(_mapTrefleRecord)
            .toList();
      }

      throw PlantApiException(
        'The plant database returned status ${response.statusCode}.',
      );
    } catch (e) {
      if (e is PlantApiException) rethrow;
      throw const PlantApiException(
        'Could not reach the plant database. Please try again later.',
      );
    }
  }

  Future<Map<String, dynamic>> fetchPlantDetails(String path) async {
    final token = _apiToken?.trim();
    if (token == null || token.isEmpty) {
      throw const PlantApiException(
        'Missing Trefle API token. Add TREFLE_API_TOKEN to your .env file.',
      );
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl$path',
      ).replace(queryParameters: {'token': token});
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          throw const PlantApiException(
            'The plant database is not returning JSON right now.',
          );
        }

        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic> ||
            decoded['data'] is! Map<String, dynamic>) {
          throw const PlantApiException(
            'The plant details were not in the expected format.',
          );
        }

        return _mapTrefleDetails(decoded['data'] as Map<String, dynamic>);
      }

      throw PlantApiException(
        'The plant database returned status ${response.statusCode}.',
      );
    } catch (e) {
      if (e is PlantApiException) rethrow;
      throw const PlantApiException(
        'Could not reach the plant database. Please try again later.',
      );
    }
  }

  Map<String, dynamic> _mapTrefleRecord(Map<String, dynamic> record) {
    final commonName = record['common_name'] as String?;
    final scientificName = record['scientific_name'] as String?;
    final family = record['family_common_name'] ?? record['family'];
    final links = record['links'];

    return {
      'name': _formatPlantName(commonName ?? scientificName ?? 'Unknown Plant'),
      'description': _buildDescription(scientificName, family),
      'main_image_path': record['image_url'],
      'common_name': commonName,
      'scientific_name': scientificName,
      'family': record['family'],
      'family_common_name': record['family_common_name'],
      'genus': record['genus'],
      'status': record['status'],
      'year': record['year'],
      'bibliography': record['bibliography'],
      'synonyms': record['synonyms'],
      'duration': record['duration'],
      'edible': record['edible'],
      'vegetable': record['vegetable'],
      'edible_part': record['edible_part'],
      'observations': record['observations'],
      'plant_detail_path': links is Map<String, dynamic>
          ? links['plant'] ?? links['self']
          : null,
    };
  }

  Map<String, dynamic> _mapTrefleDetails(Map<String, dynamic> record) {
    final mainSpecies = _asMap(record['main_species']);
    final details = mainSpecies ?? record;
    final growth = _asMap(details['growth']);
    final specifications = _asMap(details['specifications']);
    final flower = _asMap(details['flower']);
    final foliage = _asMap(details['foliage']);
    final fruitOrSeed = _asMap(details['fruit_or_seed']);

    return {
      ..._mapTrefleRecord(details),
      'duration': details['duration'],
      'edible': details['edible'],
      'vegetable': details['vegetable'],
      'edible_part': details['edible_part'],
      'observations': details['observations'],
      'days_to_harvest': growth?['days_to_harvest'],
      'sowing': growth?['sowing'],
      'growth_description': growth?['description'],
      'light': growth?['light'],
      'soil_humidity': growth?['soil_humidity'],
      'soil_texture': growth?['soil_texture'],
      'soil_nutriments': growth?['soil_nutriments'],
      'ph_minimum': growth?['ph_minimum'],
      'ph_maximum': growth?['ph_maximum'],
      'minimum_temperature': _formatMeasure(growth?['minimum_temperature']),
      'maximum_temperature': _formatMeasure(growth?['maximum_temperature']),
      'minimum_root_depth': _formatMeasure(growth?['minimum_root_depth']),
      'row_spacing': _formatMeasure(growth?['row_spacing']),
      'spread': _formatMeasure(growth?['spread']),
      'growth_months': growth?['growth_months'],
      'bloom_months': growth?['bloom_months'],
      'fruit_months': growth?['fruit_months'],
      'growth_habit': specifications?['growth_habit'],
      'growth_form': specifications?['growth_form'],
      'growth_rate': specifications?['growth_rate'],
      'toxicity': specifications?['toxicity'],
      'average_height': _formatMeasure(specifications?['average_height']),
      'maximum_height': _formatMeasure(specifications?['maximum_height']),
      'flower_color': flower?['color'],
      'foliage_color': foliage?['color'],
      'foliage_texture': foliage?['texture'],
      'fruit_color': fruitOrSeed?['color'],
    };
  }

  Map<String, dynamic>? _asMap(Object? value) {
    return value is Map<String, dynamic> ? value : null;
  }

  String? _formatMeasure(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final amount =
        value['cm'] ?? value['mm'] ?? value['celsius'] ?? value['deg_f'];
    if (amount == null) return null;
    if (value['cm'] != null) return '$amount cm';
    if (value['mm'] != null) return '$amount mm';
    if (value['celsius'] != null) return '$amount C';
    if (value['deg_f'] != null) return '$amount F';
    return amount.toString();
  }

  String _formatPlantName(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  String _buildDescription(Object? scientificName, Object? family) {
    final details = [
      if (scientificName != null) scientificName.toString(),
      if (family != null) family.toString(),
    ];

    return details.isEmpty ? 'No description available.' : details.join(' | ');
  }
}
