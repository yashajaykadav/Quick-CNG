import 'package:quickcng/repositories/verification_repository.dart';

class AdminController {
  final VerificationRepository repository;

  AdminController(this.repository);

  /// Approve verification request
  Future<void> approveRequest(String requestId) async {
    await repository.updateVerificationStatus(
      requestId,
      'approved',
    );
  }

  /// Reject verification request
  Future<void> rejectRequest(String requestId) async {
    await repository.updateVerificationStatus(
      requestId,
      'rejected',
    );
  }
}