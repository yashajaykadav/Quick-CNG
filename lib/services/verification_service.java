//package services;
//
//
//import java.util.concurrent.Future;
//
//class VerificationService {
//    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//    // Submit verification request
//    Future<String> submitVerificationRequest({
//        required String userId,
//                required String fullName,
//        required String email,
//                required String stationName,
//        String? stationId,
//                required String contact,
//        required UserRole role,
//                String? documentUrl,
//    }) async {
//        // Check if user already has a pending request
//        final existing = await _firestore
//        .collection('verification_requests')
//                .where('userId', isEqualTo: userId)
//        .where('status', isEqualTo: VerificationStatus.pending.name)
//        .get();
//
//        if (existing.docs.isNotEmpty) {
//            throw Exception('You already have a pending verification request');
//        }
//
//        final request = VerificationRequest(
//                id: '', // Will be set by Firestore
//                userId: userId,
//                fullName: fullName,
//                email: email,
//                stationName: stationName,
//                stationId: stationId,
//                contact: contact,
//                role: role,
//                createdAt: DateTime.now(),
//                documentUrl: documentUrl,
//    );
//
//        final doc = await _firestore
//        .collection('verification_requests')
//                .add(request.toMap());
//
//        return doc.id;
//    }
//
//    // Admin: Get all pending requests
//    Stream<List<VerificationRequest>> getPendingRequests() {
//        return _firestore
//                .collection('verification_requests')
//                .where('status', isEqualTo: VerificationStatus.pending.name)
//        .orderBy('createdAt', descending: true)
//        .snapshots()
//                .map((snapshot) => snapshot.docs
//                        .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
//                        .toList());
//    }
//
//    // Admin: Approve request
//    Future<void> approveRequest({
//        required String requestId,
//                required String adminUid,
//        required String stationId, // Station to assign
//    }) async {
//        final batch = _firestore.batch();
//
//        // Get the request
//        final requestDoc = await _firestore
//        .collection('verification_requests')
//                .doc(requestId)
//                .get();
//
//        if (!requestDoc.exists) {
//            throw Exception('Request not found');
//        }
//
//        final request = VerificationRequest.fromMap(
//                requestDoc.id,
//                requestDoc.data()!,
//    );
//
//        // Update verification request
//        batch.update(
//                _firestore.collection('verification_requests').doc(requestId),
//                {
//                        'status': VerificationStatus.approved.name,
//                'processedAt': FieldValue.serverTimestamp(),
//                'processedBy': adminUid,
//                'stationId': stationId,
//      },
//    );
//
//        // Update user role
//        batch.update(
//                _firestore.collection('users').doc(request.userId),
//                {
//                        'role': request.role.name,
//                'stationId': stationId,
//                'updatedAt': FieldValue.serverTimestamp(),
//      },
//    );
//
//        await batch.commit();
//    }
//
//    // Admin: Reject request
//    Future<void> rejectRequest({
//        required String requestId,
//                required String adminUid,
//        required String reason,
//    }) async {
//        await _firestore.collection('verification_requests').doc(requestId).update({
//                'status': VerificationStatus.rejected.name,
//                'processedAt': FieldValue.serverTimestamp(),
//                'processedBy': adminUid,
//                'rejectionReason': reason,
//    });
//    }
//
//    // Get user's verification history
//    Stream<List<VerificationRequest>> getUserRequests(String userId) {
//        return _firestore
//                .collection('verification_requests')
//                .where('userId', isEqualTo: userId)
//        .orderBy('createdAt', descending: true)
//        .snapshots()
//                .map((snapshot) => snapshot.docs
//                        .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
//                        .toList());
//    }
//
//    // Check if user can submit request
//    Future<bool> canSubmitRequest(String userId) async {
//        final pending = await _firestore
//        .collection('verification_requests')
//                .where('userId', isEqualTo: userId)
//        .where('status', isEqualTo: VerificationStatus.pending.name)
//        .get();
//
//        return pending.docs.isEmpty;
//    }
//}