import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/station.dart';
import '../models/report.dart';

/// State class for Station Details
class StationDetailState {
  final Station? station;
  final List<Report> reports;
  final bool isLoading;
  final String? error;

  StationDetailState({
    this.station,
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  StationDetailState copyWith({
    Station? station,
    List<Report>? reports,
    bool? isLoading,
    String? error,
  }) {
    return StationDetailState(
      station: station ?? this.station,
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing individual station details
class StationNotifier extends StateNotifier<StationDetailState> {
  final String stationId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _stationSubscription;
  StreamSubscription<QuerySnapshot>? _reportsSubscription;

  StationNotifier(this.stationId) : super(StationDetailState(isLoading: true)) {
    _loadStationDetails();
    _loadReports();
  }

  /// Load station basic info
  void _loadStationDetails() {
    _stationSubscription = _firestore
        .collection('stations')
        .doc(stationId)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          final station = Station.fromMap(snapshot.id, snapshot.data()!);
          state = state.copyWith(
            station: station,
            isLoading: false,
            error: null,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Station not found',
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  /// Load reports from sub-collection
  void _loadReports() {
    _reportsSubscription = _firestore
        .collection('stations')
        .doc(stationId)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        final reports = snapshot.docs.map((doc) {
          final data = doc.data();
          return Report(
            traffic: data['traffic'] ?? 'Unknown',
            isAvailable: data['isAvailable'] ?? true,
            time: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();

        state = state.copyWith(reports: reports);
      },
      onError: (error) {
        print('Error loading reports: $error');
      },
    );
  }

  /// Add a new report
  Future<void> addReport(String traffic) async {
    try {
      await _firestore
          .collection('stations')
          .doc(stationId)
          .collection('reports')
          .add({
        'traffic': traffic,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
        'userId': 'anonymous', // You can get from AuthService
      });
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    }
  }

  /// Get report statistics
  Map<String, int> getReportStats() {
    final stats = <String, int>{
      'Low': 0,
      'Normal': 0,
      'High': 0,
    };

    for (var report in state.reports) {
      stats[report.traffic] = (stats[report.traffic] ?? 0) + 1;
    }

    return stats;
  }

  /// Get recent reports (last N reports)
  List<Report> getRecentReports(int count) {
    return state.reports.take(count).toList();
  }

  @override
  void dispose() {
    _stationSubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }
}

/// Provider factory for individual stations
final stationNotifierProvider = StateNotifierProvider.family<
    StationNotifier, 
    StationDetailState, 
    String
>((ref, stationId) {
  return StationNotifier(stationId);
});