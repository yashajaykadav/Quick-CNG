import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickcng/models/verification_request.dart';
import 'package:quickcng/services/firestore_services.dart';

class VerificationRepository {
  final FirestoreService service;

  VerificationRepository(this.service);

  Stream<List<VerificationRequest>> getUserVerificationRequests(String userId) {
    return service.db
        .collection('verification_requests')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
              .toList();
          // Sort locally to avoid needing a Firestore composite index
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<VerificationRequest>> getPendingVerificationRequests() {
    return service.db
        .collection('verification_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
              .toList();
          // Sort locally to avoid needing a Firestore composite index
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> updateVerificationStatus(String requestId, String status) async {
    await service.db.collection('verification_requests').doc(requestId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
