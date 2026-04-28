import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantApiService {
  static const String _baseUrl = 'https://openfarm.cc/api/v1/crops';

  Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?filter=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> records = data['data'];
        return records.map((e) => e['attributes'] as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
