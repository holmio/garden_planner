import 'package:flutter_test/flutter_test.dart';
import 'package:garden_planner/data/datasources/plant_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('searchPlants parses OpenFarm crop attributes', () async {
    final service = PlantApiService(
      client: MockClient((request) async {
        expect(request.url.queryParameters['filter'], 'tomato');
        return http.Response(
          '{"data":[{"attributes":{"name":"Tomato","description":"A crop"}}]}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final plants = await service.searchPlants(' tomato ');

    expect(plants, [
      {'name': 'Tomato', 'description': 'A crop'},
    ]);
  });

  test('searchPlants reports non-JSON responses', () async {
    final service = PlantApiService(
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
