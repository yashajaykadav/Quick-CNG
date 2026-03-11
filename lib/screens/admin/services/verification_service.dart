import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> pendingRequests() {
    return _db
        .collection('verification_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> processRequest(
    String requestId,
    String userId,
    String status, {
    String? role,
    String? stationId,
  }) async {
    final batch = _db.batch();

    final requestRef =
        _db.collection('verification_requests').doc(requestId);

    batch.update(requestRef, {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (status == 'approved' && role != null) {
      final userRef = _db.collection('users').doc(userId);

      final updates = {'role': role};

      if (stationId != null) {
        updates['stationId'] = stationId;
      }

      batch.update(userRef, updates);
    }

    await batch.commit();
  }
}