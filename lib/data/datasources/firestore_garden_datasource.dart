import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/garden.dart';
import '../models/garden_model.dart';
import '../models/terrace_model.dart';

class FirestoreGardenDataSource {
  final FirebaseFirestore _firestore;

  FirestoreGardenDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<GardenModel> getGarden(
    String userId, {
    String gardenId = Garden.defaultGardenId,
  }) async {
    final gardenDoc = _gardenDocument(userId, gardenId);
    final gardenSnapshot = await gardenDoc.get();
    final terraceSnapshot = await gardenDoc.collection('terraces').get();

    if (!gardenSnapshot.exists && terraceSnapshot.docs.isEmpty) {
      return await _getLegacyDefaultGarden(userId, gardenId);
    }

    return GardenModel.fromFirestore(
      id: gardenId,
      data: gardenSnapshot.data(),
      terraces: terraceSnapshot.docs
          .map((doc) => TerraceModel.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<void> saveGarden(String userId, GardenModel garden) async {
    final batch = _firestore.batch();
    final gardenDoc = _gardenDocument(userId, garden.id);
    final terraceCollection = gardenDoc.collection('terraces');
    final existingTerraces = await terraceCollection.get();
    final currentTerraceIds = garden.terraceModels
        .map((terrace) => terrace.id)
        .toSet();

    batch.set(gardenDoc, garden.toFirestore());

    for (final terraceDoc in existingTerraces.docs) {
      if (!currentTerraceIds.contains(terraceDoc.id)) {
        batch.delete(terraceDoc.reference);
      }
    }

    for (final terrace in garden.terraceModels) {
      batch.set(terraceCollection.doc(terrace.id), terrace.toJson());
    }

    await batch.commit();
  }

  Future<GardenModel> _getLegacyDefaultGarden(
    String userId,
    String gardenId,
  ) async {
    final settingsDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('garden')
        .doc('settings')
        .get();
    final terraceSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('terraces')
        .get();

    return GardenModel.fromFirestore(
      id: gardenId,
      data: settingsDoc.data(),
      terraces: terraceSnapshot.docs
          .map((doc) => TerraceModel.fromJson(doc.data()))
          .toList(),
    );
  }

  DocumentReference<Map<String, dynamic>> _gardenDocument(
    String userId,
    String gardenId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('gardens')
        .doc(gardenId);
  }
}
