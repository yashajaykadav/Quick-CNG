import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/services/report_engine.dart';
import 'package:quickcng/models/station.dart';

class StationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateStationStatus(String stationId) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(hours: 3)),
      );

      final reportsSnapshot = await _firestore
          .collection('cng_stations')
          .doc(stationId)
          .collection('reports')
          .where('createdAt', isGreaterThan: cutoff)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final reports = reportsSnapshot.docs
          .map((doc) => Report.fromDocument(doc))
          .toList();

      final result = ReportEngine.calculateStatus(reports);

      await _firestore.collection('cng_stations').doc(stationId).update({
        'traffic': result.traffic.name,
        'status': result.isAvailable
            ? StationStatus.available.name
            : StationStatus.unavailable.name,
        'reportCount': result.reportCount,
        'confidence': result.confidence,
        'freshnessMinutes': result.freshnessMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Station>> fetchStationsWithDistance(Position userPosition) async {
    final snapshot = await _firestore.collection('cng_stations').get();

    return snapshot.docs.map((doc) {
      final station = Station.fromMap(doc.id, doc.data());

      final distanceKm =
          Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            station.latitude,
            station.longitude,
          ) /
          1000;

      return station.copyWith(distance: distanceKm);
    }).toList();
  }
}
