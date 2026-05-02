import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantApiException implements Exception {
  final String message;

  const PlantApiException(this.message);

  @override
  String toString() => message;
}

class PlantApiService {
  static const String _baseUrl = 'https://openfarm.cc/api/v1/crops';

  final http.Client _client;

  PlantApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'filter': trimmedQuery});
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
            .map((record) => record['attributes'])
            .whereType<Map<String, dynamic>>()
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
}
