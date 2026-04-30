import '../../domain/entities/terrace.dart';

abstract class TerraceRepository {
  Future<List<Terrace>> getTerraces(String userId);
  Future<void> saveTerraces(String userId, List<Terrace> terraces);
}
