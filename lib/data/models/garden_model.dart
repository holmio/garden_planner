import '../../domain/entities/garden.dart';
import '../../domain/entities/garden_size.dart';
import 'terrace_model.dart';

class GardenModel extends Garden {
  const GardenModel({
    required super.id,
    required super.name,
    required super.size,
    required super.terraces,
  });

  factory GardenModel.fromFirestore({
    required String id,
    required Map<String, dynamic>? data,
    required List<TerraceModel> terraces,
  }) {
    return GardenModel(
      id: id,
      name: data?['name'] as String? ?? Garden.defaultGardenName,
      size: GardenSize(
        width:
            (data?['width'] as num?)?.toDouble() ??
            GardenSize.defaultSize.width,
        height:
            (data?['height'] as num?)?.toDouble() ??
            GardenSize.defaultSize.height,
      ),
      terraces: terraces,
    );
  }

  factory GardenModel.fromEntity(Garden garden) {
    return GardenModel(
      id: garden.id,
      name: garden.name,
      size: garden.size,
      terraces: garden.terraces,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'width': size.width, 'height': size.height};
  }

  List<TerraceModel> get terraceModels {
    return terraces.map((terrace) => TerraceModel.fromEntity(terrace)).toList();
  }
}
