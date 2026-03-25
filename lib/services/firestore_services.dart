import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/services/worker_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore get db => _db;
  FirebaseAuth get auth => _auth;



  /// Submit a verification request for owner/worker role
  Future<void> submitVerificationRequest({
    required String userId,
    required String fullName,
    required String stationId,
    required String stationName,
    required String contact,
    required String role, // 'owner' or 'worker'
  }) async {
    try {
      await _db.collection('verification_requests').add({
        'userId': userId,
        'fullName': fullName,
        'stationId': stationId,
        'stationName': stationName,
        'contact': contact,
        'role': role,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit verification request: $e');
    }
  }

  /// Check if current user already has a pending/approved/rejected verification request
  Future<Map<String, dynamic>?> checkExistingVerificationRequest() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _db
        .collection('verification_requests')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return {'id': doc.id, ...doc.data()};
  }

  /// Fetch current user profile from Firestore
  Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return {'uid': user.uid, ...doc.data()!};
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.collection('users').doc(uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Stream<QuerySnapshot> pendingVerificationRequests() {
    return _db
        .collection('verification_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get reports submitted by the current user
  Stream<List<Report>> getUserReports() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collectionGroup('reports')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Delete a report and update station status
  Future<void> deleteReport(Report report) async {
    if (report.stationId == null) return;

    try {
      final stationRef = _db.collection('cng_stations').doc(report.stationId);
      final reportRef = stationRef.collection('reports').doc(report.id);

      // 1️⃣ Delete the report
      await reportRef.delete();

      // 2️⃣ Calculate new status via Worker
      final result = await WorkerService.getStationStatus(report.stationId!);

      // 4️⃣ Update station
      await stationRef.update({
        'traffic': result['traffic'] ?? TrafficLevel.normal.name,
        'status': (result['isAvailable'] ?? true)
            ? StationStatus.available.name
            : StationStatus.unavailable.name,
        'reportCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
        'confidence': result['confidence'] ?? 0.0,
        'freshnessMinutes': result['freshnessMinutes'] ?? 0,
      });
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
