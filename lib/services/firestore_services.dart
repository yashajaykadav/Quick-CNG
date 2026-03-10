import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/services/report_engine.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch all stations stream
  Stream<List<Station>> getStations() {
    return _db
        .collection('cng_stations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<Station?> getStation(String stationId) {
    return _db.collection('cng_stations').doc(stationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Station.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> addReport(
    String stationId,
    TrafficLevel traffic, {
    required bool isAvailable,
    String? userName,
    UserRole? userRole,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final stationRef = _db.collection('cng_stations').doc(stationId);
    final reportRef = stationRef.collection('reports').doc();

    try {
      // 1️⃣ Create report
      await reportRef.set({
        'traffic': traffic.name,
        'isAvailable': isAvailable,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'userName': userName ?? user.email ?? 'Anonymous',
        'userRole': (userRole ?? UserRole.user).name,
      });

      // 2️⃣ Fetch recent reports
      final reportsSnapshot = await stationRef
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final reports = reportsSnapshot.docs
          .map((doc) => Report.fromMap(doc.id, doc.data()))
          .toList();

      // 3️⃣ Calculate status
      final result = ReportEngine.calculateStatus(reports);

      // 4️⃣ Update station
      await stationRef.update({
        'traffic': result.traffic.name,
        'status': result.isAvailable
            ? StationStatus.available.name
            : StationStatus.unavailable.name,
        'reportCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add report: $e');
    }
  }
  // /// Get real-time traffic for a station
  // Stream<TrafficLevel> getStationTraffic(String stationId) {
  //   final cutoff = Timestamp.fromDate(
  //     DateTime.now().subtract(const Duration(hours: 3)),
  //   );
  //
  //   return _db
  //       .collection('cng_stations')
  //       .doc(stationId)
  //       .collection('reports')
  //       .where('createdAt', isGreaterThan: cutoff)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     if (snapshot.docs.isEmpty) return TrafficLevel.normal;
  //
  //     final reports = snapshot.docs
  //         .map((doc) => Report.fromMap(doc.id, doc.data()))
  //         .toList();
  //
  //     final result = ReportEngine.calculateStatus(reports);
  //     return result.traffic;
  //   });
  // }

  // /// Get real-time availability for a station
  // Stream<bool> getStationAvailability(String stationId) {
  //   final cutoff = Timestamp.fromDate(
  //     DateTime.now().subtract(const Duration(hours: 3)),
  //   );
  //
  //   return _db
  //       .collection('cng_stations')
  //       .doc(stationId)
  //       .collection('reports')
  //       .where('createdAt', isGreaterThan: cutoff)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     if (snapshot.docs.isEmpty) return true;
  //
  //     final reports = snapshot.docs
  //         .map((doc) => Report.fromMap(doc.id, doc.data()))
  //         .toList();
  //
  //     final result = ReportEngine.calculateStatus(reports);
  //     return result.isAvailable;
  //   });
  // }

  /// Get recent reports for a station
  Stream<List<Report>> getStationReports(String stationId, {int limit = 20}) {
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 3)),
    );

    return _db
        .collection('cng_stations')
        .doc(stationId)
        .collection('reports')
        .where('createdAt', isGreaterThan: cutoff)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Create a new station (Admin only)
  Future<String> createStation(Map<String, dynamic> stationData) async {
    try {
      final docRef = await _db.collection('cng_stations').add({
        ...stationData,
        'reportCount': 0,
        'status': StationStatus.available.name,
        'traffic': TrafficLevel.normal.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create station: $e');
    }
  }

  /// Update station details (Admin/Owner only)
  Future<void> updateStation(
    String stationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.collection('cng_stations').doc(stationId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update station: $e');
    }
  }

  /// Delete station (Admin only)
  Future<void> deleteStation(String stationId) async {
    try {
      final batch = _db.batch();

      // Delete all reports
      final reportsSnapshot = await _db
          .collection('cng_stations')
          .doc(stationId)
          .collection('reports')
          .get();

      for (var doc in reportsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete station
      batch.delete(_db.collection('cng_stations').doc(stationId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete station: $e');
    }
  }

  /// Get stations by city
  Stream<List<Station>> getStationsByCity(String city) {
    return _db
        .collection('cng_stations')
        .where('city', isEqualTo: city)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Get stations by state
  Stream<List<Station>> getStationsByState(String state) {
    return _db
        .collection('cng_stations')
        .where('state', isEqualTo: state)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Get stations by provider
  Stream<List<Station>> getStationsByProvider(String provider) {
    return _db
        .collection('cng_stations')
        .where('provider', isEqualTo: provider)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Search stations by name
  Stream<List<Station>> searchStations(String query) {
    return _db
        .collection('cng_stations')
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final stationsSnapshot = await _db.collection('cng_stations').get();
      final stations = stationsSnapshot.docs
          .map((doc) => Station.fromMap(doc.id, doc.data()))
          .toList();

      final totalStations = stations.length;
      final availableStations = stations
          .where((s) => s.status == StationStatus.available)
          .length;
      final unavailableStations = stations
          .where((s) => s.status == StationStatus.unavailable)
          .length;
      final closedStations = stations
          .where((s) => s.status == StationStatus.closed)
          .length;

      final totalReports = stations.fold<int>(
        0,
        (sums, station) => sums + station.reportCount,
      );

      return {
        'totalStations': totalStations,
        'availableStations': availableStations,
        'unavailableStations': unavailableStations,
        'closedStations': closedStations,
        'totalReports': totalReports,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Fetch all stations once (for dropdowns/pickers, not real-time)
  Future<List<Map<String, String>>> fetchAllStationsOnce() async {
    final snapshot = await _db.collection('cng_stations').orderBy('name').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': (data['name'] ?? '') as String,
        'city': (data['city'] ?? '') as String,
      };
    }).toList();
  }

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
}
