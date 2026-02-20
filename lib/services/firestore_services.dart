import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Station>> getStations() {
    
    return _db
        .collection('stations')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addReport(String stationId, String traffic) async {
  final user = FirebaseAuth.instance.currentUser;

  await _db
      .collection('stations')
      .doc(stationId)
      .collection('reports')
      .add({
    'traffic': traffic,
    'createdAt': Timestamp.now(),
    'userId': user?.uid,
  });
}
}
