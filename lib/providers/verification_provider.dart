import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/verification_request.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/providers/auth_provider.dart';

// User's verification requests
final userVerificationRequestsProvider = StreamProvider<List<VerificationRequest>>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('verification_requests')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
      .toList());
});

// Check if user has pending request
final hasPendingRequestProvider = Provider<bool>((ref) {
  final requests = ref.watch(userVerificationRequestsProvider).value ?? [];
  return requests.any((r) => r.status == VerificationStatus.pending);
});

// Admin: All pending verification requests
final pendingVerificationRequestsProvider = StreamProvider<List<VerificationRequest>>((ref) {
  return FirebaseFirestore.instance
      .collection('verification_requests')
      .where('status', isEqualTo: VerificationStatus.pending.name)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => VerificationRequest.fromMap(doc.id, doc.data()))
      .toList());
});

// Pending requests count (for admin badge)
final pendingRequestsCountProvider = Provider<int>((ref) {
  final requests = ref.watch(pendingVerificationRequestsProvider).value ?? [];
  return requests.length;
});