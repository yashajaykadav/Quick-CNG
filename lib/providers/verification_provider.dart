import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/controllers/admin_controller.dart';
import 'package:quickcng/models/verification_request.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/providers/auth_provider.dart';
import 'package:quickcng/providers/firestore_provider.dart';
import 'package:quickcng/repositories/verification_repository.dart';

/// Repository Provider
final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return VerificationRepository(service);
});

/// User's verification requests
final userVerificationRequestsProvider =
    StreamProvider<List<VerificationRequest>>((ref) {

  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(verificationRepositoryProvider);

  return repo.getUserVerificationRequests(user.uid);
});


/// Check if user has pending request
final hasPendingRequestProvider = Provider<bool>((ref) {
  final requests = ref.watch(userVerificationRequestsProvider).value ?? [];

  return requests.any((r) => r.status == VerificationStatus.pending);
});


/// Admin: all pending verification requests
final pendingVerificationRequestsProvider =
    StreamProvider<List<VerificationRequest>>((ref) {

  final repo = ref.watch(verificationRepositoryProvider);

  return repo.getPendingVerificationRequests();
});


/// Pending requests count (for admin badge)
final pendingRequestsCountProvider = Provider<int>((ref) {
  final requests =
      ref.watch(pendingVerificationRequestsProvider).value ?? [];

  return requests.length;
});

final adminControllerProvider = Provider<AdminController>((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return AdminController(repo);
});