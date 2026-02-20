import 'package:cloud_firestore/cloud_firestore.dart';

import 'report.dart';

class Station {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String status;
  final String traffic;
  final DateTime updatedAt;
  final List<Report> reports;

  Station({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.status,
    required this.traffic,
    required this.updatedAt,
    required this.reports,
  });
  // station.dart
factory Station.fromMap(String id, Map<String, dynamic> data) {
  return Station(
    id: id,
    name: data['name'] ?? '',
    lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
    lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
    status: data['status'] ?? 'Unknown',
traffic: data['traffic'] ?? 'low',
    updatedAt: (data['updatedat'] as Timestamp?)?.toDate() ?? DateTime.now(),
    reports: [], 
  );
}

  Station copyWith({
    List<Report>? reports,
  }) {
    return Station(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      status: status,
      traffic: traffic,
      updatedAt: updatedAt,
      reports: reports ?? this.reports,
    );
  }
}
