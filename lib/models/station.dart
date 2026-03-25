import 'package:quickcng/models/enums.dart';
import 'package:quickcng/models/report.dart';

class Station {
  final String id; // We'll map stationId to this
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
  final double? confidence;
  final int? freshnessMinutes;
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
    this.confidence,
    this.freshnessMinutes,
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

    final isRecent = DateTime.now().difference(latest.createdAt).inMinutes < 60;

    return latest.isVerified && isRecent;
  }

  /// 🟢 NEW: Cloudflare Factory
  /// Replaces Station.fromMap to handle JSON from Workers/D1
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['stationId'] ?? '',
      stationId: json['stationId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      // D1 returns these as doubles/nums directly
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      provider: json['provider'] ?? '',
      // SQLite stores booleans as 0 or 1. This check handles both.
      is24Hours: json['is24Hours'] == 1 || json['is24Hours'] == true,
      status: _parseStatus(json['status']),
      traffic: _parseTraffic(json['traffic']),
      // SQLite/D1 strings look like "2026-03-16 12:00:00"
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      reportCount: json['reportCount'] ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble(),
      freshnessMinutes: json['freshnessMinutes'] as int?,
      reports: [], // We will handle Reports in a separate SQL table later
    );
  }

  /// --------------------------
  /// Enum Parsing
  /// --------------------------

  static StationStatus _parseStatus(dynamic value) {
    if (value == null) return StationStatus.available;
    try {
      return StationStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      );
    } catch (_) {
      return StationStatus.available;
    }
  }

  static TrafficLevel _parseTraffic(dynamic value) {
    if (value == null) return TrafficLevel.normal;
    try {
      return TrafficLevel.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      );
    } catch (_) {
      return TrafficLevel.normal;
    }
  }

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
    double? confidence,
    int? freshnessMinutes,
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
      confidence: confidence ?? this.confidence,
      freshnessMinutes: freshnessMinutes ?? this.freshnessMinutes,
      distance: distance ?? this.distance,
    );
  }
}
