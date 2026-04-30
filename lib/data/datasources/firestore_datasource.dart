import 'package:cloud_firestore/cloud_firestore.dart';
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
    final collection = _firestore.collection('users').doc(userId).collection('terraces');

    // For simplicity, we just save them. In a real app we might want to diff
    // or use specific document IDs matching the terrace.id
    for (final terrace in terraces) {
      final docRef = collection.doc(terrace.id);
      batch.set(docRef, terrace.toJson());
    }

    await batch.commit();
  }
}
