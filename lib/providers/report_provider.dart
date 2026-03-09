import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/report.dart';

// Reports for a specific station
final stationReportsProvider = StreamProvider.family<List<Report>, String>((ref, stationId) {
  return FirebaseFirestore.instance
      .collection('cng_stations')
      .doc(stationId)
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .limit(20) // Limit to recent reports
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Report.fromMap(doc.id, doc.data()))
      .toList());
});

// Recent reports for a station (last hour)
final recentStationReportsProvider = Provider.family<List<Report>, String>((ref, stationId) {
  final reports = ref.watch(stationReportsProvider(stationId)).value ?? [];
  final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

  return reports.where((r) => r.createdAt.isAfter(oneHourAgo)).toList();
});

// Latest official report (from verified user)
final latestOfficialReportProvider = Provider.family<Report?, String>((ref, stationId) {
  final reports = ref.watch(recentStationReportsProvider(stationId));

  final verifiedReports = reports.where((r) => r.isVerified).toList();

  if (verifiedReports.isEmpty) return null;
  return verifiedReports.first; // Already sorted by createdAt desc
});