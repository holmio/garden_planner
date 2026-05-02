import '../../domain/entities/garden_size.dart';
import '../../domain/entities/terrace.dart';

abstract class TerraceRepository {
  Future<List<Terrace>> getTerraces(String userId);
  Future<void> saveTerraces(String userId, List<Terrace> terraces);
  Future<GardenSize> getGardenSize(String userId);
  Future<void> saveGardenSize(String userId, GardenSize gardenSize);
}
