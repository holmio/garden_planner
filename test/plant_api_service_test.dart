import 'package:flutter_test/flutter_test.dart';
import 'package:garden_planner/data/datasources/plant_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('searchPlants parses Trefle plant search results', () async {
    final service = PlantApiService(
      apiToken: 'test-token',
      client: MockClient((request) async {
        expect(request.url.host, 'trefle.io');
        expect(request.url.path, '/api/v1/plants/search');
        expect(request.url.queryParameters['token'], 'test-token');
        expect(request.url.queryParameters['q'], 'tomato');
        expect(request.url.queryParameters['filter[edible]'], 'true');
        expect(request.url.queryParameters['filter[vegetable]'], 'true');
        return http.Response(
          '''
          {
            "data": [
              {
                "common_name": "garden tomato",
                "scientific_name": "Solanum lycopersicum",
                "family_common_name": "Nightshade family",
                "edible": true,
                "vegetable": true,
                "edible_part": ["fruit"],
                "image_url": "https://example.com/tomato.jpg",
                "links": {
                  "plant": "/api/v1/plants/solanum-lycopersicum"
                }
              }
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final plants = await service.searchPlants(' tomato ');

    expect(plants, [
      {
        'name': 'Garden tomato',
        'description': 'Solanum lycopersicum | Nightshade family',
        'main_image_path': 'https://example.com/tomato.jpg',
        'common_name': 'garden tomato',
        'scientific_name': 'Solanum lycopersicum',
        'family': null,
        'family_common_name': 'Nightshade family',
        'genus': null,
        'status': null,
        'year': null,
        'bibliography': null,
        'synonyms': null,
        'duration': null,
        'edible': true,
        'vegetable': true,
        'edible_part': ['fruit'],
        'observations': null,
        'plant_detail_path': '/api/v1/plants/solanum-lycopersicum',
      },
    ]);
  });

  test('fetchPlantDetails parses gardening and farming fields', () async {
    final service = PlantApiService(
      apiToken: 'test-token',
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/plants/solanum-lycopersicum');
        expect(request.url.queryParameters['token'], 'test-token');
        return http.Response(
          '''
          {
            "data": {
              "main_species": {
                "common_name": "garden tomato",
                "scientific_name": "Solanum lycopersicum",
                "duration": ["Annual"],
                "edible": true,
                "vegetable": true,
                "edible_part": ["fruit"],
                "observations": "Commonly grown for its edible fruit.",
                "growth": {
                  "days_to_harvest": 80,
                  "light": 8,
                  "ph_minimum": 5.5,
                  "ph_maximum": 7.5,
                  "row_spacing": {"cm": 60}
                },
                "specifications": {
                  "growth_habit": "forb/herb",
                  "toxicity": "low"
                },
                "flower": {"color": ["yellow"]}
              }
            }
          }
          ''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final details = await service.fetchPlantDetails(
      '/api/v1/plants/solanum-lycopersicum',
    );

    expect(details['name'], 'Garden tomato');
    expect(details['duration'], ['Annual']);
    expect(details['edible'], true);
    expect(details['vegetable'], true);
    expect(details['days_to_harvest'], 80);
    expect(details['light'], 8);
    expect(details['ph_minimum'], 5.5);
    expect(details['ph_maximum'], 7.5);
    expect(details['row_spacing'], '60 cm');
    expect(details['growth_habit'], 'forb/herb');
    expect(details['toxicity'], 'low');
    expect(details['flower_color'], ['yellow']);
  });

  test('searchPlants reports a missing Trefle token', () async {
    final service = PlantApiService(
      apiToken: '',
      client: MockClient((request) async {
        fail('searchPlants should not make a request without an API token.');
      }),
    );

    expect(
      () => service.searchPlants('tomato'),
      throwsA(isA<PlantApiException>()),
    );
  });

  test('searchPlants reports non-JSON responses', () async {
    final service = PlantApiService(
      apiToken: 'test-token',
      client: MockClient((request) async {
        return http.Response(
          '<html>Moved</html>',
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }),
    );

    expect(
      () => service.searchPlants('tomato'),
      throwsA(isA<PlantApiException>()),
    );
  });
}
