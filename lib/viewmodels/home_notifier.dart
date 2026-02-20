import 'dart:async';
import 'dart:math'; // ✅ ADD THIS IMPORT
import 'package:flutter_riverpod/legacy.dart';
import '../models/station.dart';
import '../services/firestore_services.dart';

class HomeNotifier extends StateNotifier<List<Station>> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Station>>? _subscription;

  HomeNotifier() : super([]) {
    _loadStations();
  }

  /// Load stations from Firestore and listen to real-time updates
  void _loadStations() {
    _subscription = _firestoreService.getStations().listen(
      (stations) {
        state = stations;
      },
      onError: (error) {
        print('Error loading stations: $error');
        state = [];
      },
    );
  }

  /// Submit a traffic report for a specific station
  Future<void> submitReport(String stationId, String traffic) async {
    try {
      await _firestoreService.addReport(stationId, traffic);
    } catch (e) {
      print('Error submitting report: $e');
      rethrow;
    }
  }

  /// Get a single station by ID
  Station? getStationById(String id) {
    try {
      return state.firstWhere((station) => station.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filter stations by traffic level
  List<Station> filterByTraffic(String traffic) {
    return state.where((station) => 
      station.traffic.toLowerCase() == traffic.toLowerCase()
    ).toList();
  }

  /// Filter stations by status (Open/Closed)
  List<Station> filterByStatus(String status) {
    return state.where((station) => 
      station.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }

  /// Get stations sorted by distance (requires lat/lng parameters)
  List<Station> getSortedByDistance(double userLat, double userLng) {
    final sorted = List<Station>.from(state);
    sorted.sort((a, b) {
      final distA = _calculateDistance(userLat, userLng, a.lat, a.lng);
      final distB = _calculateDistance(userLat, userLng, b.lat, b.lng);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  /// Calculate distance using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    // ✅ Use sin(), cos(), sqrt(), and asin() from dart:math
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _toRadians(double degree) {
    return degree * pi / 180; // ✅ Use 'pi' constant from dart:math
  }

  /// Refresh stations manually
  void refresh() {
    _subscription?.cancel();
    _loadStations();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}