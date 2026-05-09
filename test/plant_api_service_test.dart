import 'package:flutter_test/flutter_test.dart';
import 'package:garden_planner/data/datasources/plant_api_service.dart';

void main() {
  test(
    'searchPlants finds curated plants by English and European aliases',
    () async {
      final service = PlantApiService(plants: [_potato, _tomato]);

      final germanResults = await service.searchPlants(' kartoffel ');
      final englishResults = await service.searchPlants('tomato');

      expect(germanResults, hasLength(1));
      expect(germanResults.single['name'], 'Potato');
      expect(
        germanResults.single['icon_asset_path'],
        'assets/icons/plants/potato.svg',
      );
      expect(germanResults.single['plant_detail_path'], 'catalog://potato');

      expect(englishResults, hasLength(1));
      expect(englishResults.single['name'], 'Tomato');
    },
  );

  test('fetchPlantDetails returns European garden planning fields', () async {
    final service = PlantApiService(plants: [_potato]);

    final details = await service.fetchPlantDetails('catalog://potato');

    expect(details['name'], 'Potato');
    expect(details['description'], contains('tuber'));
    expect(details['days_to_harvest'], 100);
    expect(details['sowing'], 'March, April, May');
    expect(details['growth_months'], ['May', 'June', 'July', 'August']);
    expect(details['row_spacing'], '75 cm');
    expect(details['spread'], '30 cm');
    expect(details['planting_depth'], '10 cm');
    expect(details['ph_minimum'], 5.0);
    expect(details['ph_maximum'], 6.5);
    expect(details['good_companions'], ['bean', 'cabbage']);
    expect(details['bad_companions'], ['tomato', 'pepper']);
    expect(details['avoid_same_bed_years'], 3);
  });

  test('searchPlants returns no results for unknown plants', () async {
    final service = PlantApiService(plants: [_potato]);

    final results = await service.searchPlants('banana');

    expect(results, isEmpty);
  });

  test('fetchPlantDetails reports missing local catalog entries', () async {
    final service = PlantApiService(plants: [_potato]);

    expect(
      () => service.fetchPlantDetails('catalog://banana'),
      throwsA(isA<PlantApiException>()),
    );
  });
}

final _potato = {
  'id': 'potato',
  'name': 'Potato',
  'common_name': 'Potato',
  'scientific_name': 'Solanum tuberosum',
  'family': 'Solanaceae',
  'family_common_name': 'Nightshade family',
  'genus': 'Solanum',
  'aliases': ['kartoffel'],
  'category': 'vegetable',
  'plant_type': 'tuber crop',
  'difficulty': 'easy',
  'duration': ['Perennial grown as annual'],
  'growth_rate': 'medium',
  'description': 'Reliable tuber crop for loose soil.',
  'observations': 'Plant seed potatoes after hard frost risk passes.',
  'icon_asset_path': 'assets/icons/plants/potato.svg',
  'days_to_harvest': 100,
  'light': 8,
  'soil_moisture': 6,
  'soil': {
    'texture': 'loose, well-drained soil',
    'nutrients': 'medium-high',
    'ph_min': 5.0,
    'ph_max': 6.5,
  },
  'spacing': {
    'between_plants_cm': 30,
    'between_rows_cm': 75,
    'planting_depth_cm': 10,
  },
  'height_cm': {'min': 40, 'max': 80},
  'minimum_temperature': '7 C',
  'maximum_temperature': '28 C',
  'minimum_root_depth': '35 cm',
  'europe_season': {
    'sow_or_plant': ['March', 'April', 'May'],
    'main_growth': ['May', 'June', 'July', 'August'],
    'flowering': ['June', 'July'],
    'harvest': ['June', 'July', 'August', 'September'],
  },
  'care': {
    'watering': 'Keep evenly moist during tuber formation.',
    'fertilizing': 'Compost before planting.',
    'notes': 'Hill soil or mulch to prevent green tubers.',
  },
  'companions': {
    'good': ['bean', 'cabbage'],
    'bad': ['tomato', 'pepper'],
  },
  'problems': {
    'pests': ['Colorado potato beetle'],
    'diseases': ['late blight'],
    'warnings': ['Do not eat green potatoes.'],
  },
  'rotation': {
    'family': 'Solanaceae',
    'avoid_same_bed_years': 3,
    'notes': 'Rotate with legumes or leafy crops.',
  },
  'edible_parts': ['tuber'],
  'toxicity': 'Green tubers, leaves, and sprouts are toxic.',
  'flower_color': ['white', 'purple'],
  'foliage_color': ['green'],
  'fruit_color': ['yellow', 'brown'],
  'tags': ['root-crop'],
};

final _tomato = {
  ..._potato,
  'id': 'tomato',
  'name': 'Tomato',
  'common_name': 'Tomato',
  'scientific_name': 'Solanum lycopersicum',
  'aliases': ['tomate'],
  'description': 'Warm-season crop for sheltered European gardens.',
  'icon_asset_path': 'assets/icons/plants/tomato.svg',
};
