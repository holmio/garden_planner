import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/garden_size.dart';
import '../models/terrace_model.dart';

class FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<TerraceModel>> getTerraces(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('terraces')
        .get();

    return querySnapshot.docs
        .map((doc) => TerraceModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveTerraces(String userId, List<TerraceModel> terraces) async {
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('terraces');

    // For simplicity, we just save them. In a real app we might want to diff
    // or use specific document IDs matching the terrace.id
    for (final terrace in terraces) {
      final docRef = collection.doc(terrace.id);
      batch.set(docRef, terrace.toJson());
    }

    await batch.commit();
  }

  Future<GardenSize> getGardenSize(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('garden')
        .doc('settings')
        .get();

    final data = doc.data();
    if (data == null) return GardenSize.defaultSize;

    return GardenSize(
      width:
          (data['width'] as num?)?.toDouble() ?? GardenSize.defaultSize.width,
      height:
          (data['height'] as num?)?.toDouble() ?? GardenSize.defaultSize.height,
    );
  }

  Future<void> saveGardenSize(String userId, GardenSize gardenSize) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('garden')
        .doc('settings')
        .set({'width': gardenSize.width, 'height': gardenSize.height});
  }
}
