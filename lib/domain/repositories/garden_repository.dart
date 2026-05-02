import '../../domain/entities/garden.dart';

abstract class GardenRepository {
  Future<Garden> getGarden(
    String userId, {
    String gardenId = Garden.defaultGardenId,
  });
  Future<void> saveGarden(String userId, Garden garden);
}
