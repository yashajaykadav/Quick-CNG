import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/models/report.dart';

class Station {
  final String id;
  final String stationId;
  final String name;
  final String address;
  final String city;
  final String district;
  final String state;

  final double latitude;
  final double longitude;

  final String provider;
  final bool is24Hours;

  final StationStatus status;
  final TrafficLevel traffic;

  final DateTime updatedAt;

  final int reportCount;
  final List<Report> reports;

  double? distance;

  Station({
    required this.id,
    required this.stationId,
    required this.name,
    required this.address,
    required this.city,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.provider,
    required this.is24Hours,
    required this.status,
    required this.traffic,
    required this.updatedAt,
    this.reportCount = 0,
    this.reports = const [],
    this.distance,
  });

  /// --------------------------
  /// Computed properties
  /// --------------------------

  bool get isAvailable => status == StationStatus.available;

  bool get isActive => status != StationStatus.closed;

  String get displayStatus => status.displayName;

  String get fullAddress => '$address, $city, $district, $state';

  /// Check if latest report is from verified staff within 1 hour
  bool get hasOfficialUpdate {
    if (reports.isEmpty) return false;

    final latest = reports.reduce(
          (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );

    final isRecent =
        DateTime.now().difference(latest.createdAt).inMinutes < 60;

    return latest.isVerified && isRecent;
  }

  /// --------------------------
  /// Firestore Factory
  /// --------------------------

  factory Station.fromMap(String id, Map<String, dynamic> data) {
    GeoPoint? geo = data['geo'];

    return Station(
      id: id,
      stationId: data['stationId'] ?? id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? '',
      latitude: geo?.latitude ??
          (data['latitude'] as num?)?.toDouble() ??
          0.0,
      longitude: geo?.longitude ??
          (data['longitude'] as num?)?.toDouble() ??
          0.0,
      provider: data['provider'] ?? '',
      is24Hours: data['is24Hours'] ?? false,
      status: _parseStatus(data['status']),
      traffic: _parseTraffic(data['traffic']),
      updatedAt:
      (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reportCount: data['reportCount'] ?? 0,
    );
  }

  /// --------------------------
  /// Enum Parsing
  /// --------------------------

  static StationStatus _parseStatus(dynamic value) {
    if (value == null) return StationStatus.available;

    try {
      return StationStatus.values.firstWhere(
            (e) => e.name.toLowerCase() ==
            value.toString().toLowerCase(),
      );
    } catch (_) {
      return StationStatus.available;
    }
  }

  static TrafficLevel _parseTraffic(dynamic value) {
    if (value == null) return TrafficLevel.normal;

    try {
      return TrafficLevel.values.firstWhere(
            (e) => e.name.toLowerCase() ==
            value.toString().toLowerCase(),
      );
    } catch (_) {
      return TrafficLevel.normal;
    }
  }

  /// --------------------------
  /// Firestore Map
  /// --------------------------

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'name': name,
      'address': address,
      'city': city,
      'district': district,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,

      /// Recommended for geo queries
      'geo': GeoPoint(latitude, longitude),

      'provider': provider,
      'is24Hours': is24Hours,
      'status': status.name,
      'traffic': traffic.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'reportCount': reportCount,
    };
  }

  /// --------------------------
  /// Copy With
  /// --------------------------

  Station copyWith({
    String? id,
    String? stationId,
    String? name,
    String? address,
    String? city,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    String? provider,
    bool? is24Hours,
    StationStatus? status,
    TrafficLevel? traffic,
    DateTime? updatedAt,
    int? reportCount,
    List<Report>? reports,
    double? distance,
  }) {
    return Station(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      provider: provider ?? this.provider,
      is24Hours: is24Hours ?? this.is24Hours,
      status: status ?? this.status,
      traffic: traffic ?? this.traffic,
      updatedAt: updatedAt ?? this.updatedAt,
      reportCount: reportCount ?? this.reportCount,
      reports: reports ?? this.reports,
      distance: distance ?? this.distance,
    );
  }

  /// --------------------------
  /// Debug
  /// --------------------------

  @override
  String toString() {
    return 'Station('
        'id: $id, '
        'stationId: $stationId, '
        'name: $name, '
        'city: $city, '
        'status: ${status.name}, '
        'traffic: ${traffic.name}'
        ')';
  }
}