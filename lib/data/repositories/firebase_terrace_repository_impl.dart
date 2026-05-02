import '../../domain/entities/garden_size.dart';
import '../../domain/entities/terrace.dart';
import '../../domain/repositories/terrace_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../models/terrace_model.dart';

class FirebaseTerraceRepositoryImpl implements TerraceRepository {
  final FirestoreDataSource _firestoreDataSource;

  FirebaseTerraceRepositoryImpl({
    required FirestoreDataSource firestoreDataSource,
  }) : _firestoreDataSource = firestoreDataSource;

  @override
  Future<List<Terrace>> getTerraces(String userId) async {
    return await _firestoreDataSource.getTerraces(userId);
  }

  @override
  Future<void> saveTerraces(String userId, List<Terrace> terraces) async {
    final models = terraces.map((t) => TerraceModel.fromEntity(t)).toList();
    await _firestoreDataSource.saveTerraces(userId, models);
  }

  @override
  Future<GardenSize> getGardenSize(String userId) async {
    return await _firestoreDataSource.getGardenSize(userId);
  }

  @override
  Future<void> saveGardenSize(String userId, GardenSize gardenSize) async {
    await _firestoreDataSource.saveGardenSize(userId, gardenSize);
  }
}
