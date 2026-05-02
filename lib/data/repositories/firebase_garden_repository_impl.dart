import '../../domain/entities/garden.dart';
import '../../domain/repositories/garden_repository.dart';
import '../datasources/firestore_garden_datasource.dart';
import '../models/garden_model.dart';

class FirebaseGardenRepositoryImpl implements GardenRepository {
  final FirestoreGardenDataSource _gardenDataSource;

  FirebaseGardenRepositoryImpl({
    required FirestoreGardenDataSource gardenDataSource,
  }) : _gardenDataSource = gardenDataSource;

  @override
  Future<Garden> getGarden(
    String userId, {
    String gardenId = Garden.defaultGardenId,
  }) async {
    return await _gardenDataSource.getGarden(userId, gardenId: gardenId);
  }

  @override
  Future<void> saveGarden(String userId, Garden garden) async {
    await _gardenDataSource.saveGarden(userId, GardenModel.fromEntity(garden));
  }
}
