import 'package:quickcng/models/report.dart';
import 'package:quickcng/models/enums.dart';

class ReportEngine {
  /// Reports older than this are ignored
  static const int _reportWindowMinutes = 180;

  /// Official report override window
  static const int _officialWindowMinutes = 30;

  /// Main entry point
  static StationStatusResult calculateStatus(List<Report> reports) {
    final now = DateTime.now();

    if (reports.isEmpty) {
      return StationStatusResult(
        traffic: _predictTraffic(now),
        isAvailable: true,
        isOfficial: false,
        reportCount: 0,
        confidence: 0,
      );
    }

    // Remove duplicate reports from same user
    final cleanedReports = _removeDuplicateUsers(reports);

    // 1️⃣ Official override
    final official = _getLatestOfficialReport(cleanedReports, now);
    if (official != null) {
      return StationStatusResult(
        traffic: official.traffic,
        isAvailable: official.isAvailable,
        isOfficial: true,
        reportCount: cleanedReports.length,
        lastUpdateTime: official.createdAt,
        confidence: 1.0,
      );
    }

    // 2️⃣ Community weighted result
    return _calculateWeightedStatus(cleanedReports, now);
  }

  /// Remove multiple reports from same user
  static List<Report> _removeDuplicateUsers(List<Report> reports) {
    final Map<String, Report> latestReports = {};

    for (final report in reports) {
      // Prevent an attacker from generating multiple unique guest weights:
      // Group all reports missing a valid userId into a single 'anonymous' key.
      final key = (report.userId != null && report.userId!.isNotEmpty)
          ? report.userId!
          : 'anonymous_guests';

      final existing = latestReports[key];

      if (existing == null ||
          report.createdAt.isAfter(existing.createdAt)) {
        latestReports[key] = report;
      }
    }

    return latestReports.values.toList();
  }

  /// Get latest official report
  static Report? _getLatestOfficialReport(
      List<Report> reports,
      DateTime now,
      ) {
    final officialRecent = reports
        .where((r) =>
    r.isVerified &&
        now.difference(r.createdAt).inMinutes <
            _officialWindowMinutes)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return officialRecent.isNotEmpty ? officialRecent.first : null;
  }

  /// Weighted crowd calculation
  static StationStatusResult _calculateWeightedStatus(
      List<Report> reports,
      DateTime now,
      ) {
    double trafficScore = 0;
    double availabilityScore = 0;
    double totalWeight = 0;
    int validReportCount = 0;

    DateTime? newestReport;

    for (final report in reports) {
      final minutesOld =
          now.difference(report.createdAt).inMinutes;

      if (minutesOld > _reportWindowMinutes) continue;

      newestReport = newestReport == null
          ? report.createdAt
          : (report.createdAt.isAfter(newestReport)
          ? report.createdAt
          : newestReport);

      final timeFactor =
          (_reportWindowMinutes - minutesOld) /
              _reportWindowMinutes;

      final roleWeight = report.weight;

      final combinedWeight = timeFactor * roleWeight;

      trafficScore +=
          _trafficToValue(report.traffic) * combinedWeight;

      availabilityScore +=
          (report.isAvailable ? 1.0 : 0.0) * combinedWeight;

      totalWeight += combinedWeight;

      validReportCount++;
    }

    // No valid reports
    if (validReportCount == 0 || totalWeight == 0) {
      return StationStatusResult(
        traffic: _predictTraffic(now),
        isAvailable: true,
        isOfficial: false,
        reportCount: 0,
        confidence: 0,
      );
    }

    final avgTraffic = trafficScore / totalWeight;
    final avgAvailability = availabilityScore / totalWeight;

    final confidence =
    (validReportCount / 5).clamp(0, 1).toDouble();

    final freshness = newestReport == null
        ? null
        : now.difference(newestReport).inMinutes;

    return StationStatusResult(
      traffic: _valueToTraffic(avgTraffic),
      isAvailable: avgAvailability > 0.5,
      isOfficial: false,
      reportCount: validReportCount,
      lastUpdateTime: newestReport,
      freshnessMinutes: freshness,
      confidence: confidence,
    );
  }

  /// Traffic enum → numeric value
  static double _trafficToValue(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low:
        return 0.2;
      case TrafficLevel.normal:
        return 0.5;
      case TrafficLevel.high:
        return 0.8;
    }
  }

  /// Numeric value → traffic enum
  static TrafficLevel _valueToTraffic(double value) {
    if (value >= 0.65) return TrafficLevel.high;
    if (value >= 0.35) return TrafficLevel.normal;
    return TrafficLevel.low;
  }

  /// Predict traffic based on time of day
  static TrafficLevel _predictTraffic(DateTime now) {
    final hour = now.hour;

    if (hour >= 6 && hour <= 9) {
      return TrafficLevel.high;
    }

    if (hour >= 16 && hour <= 20) {
      return TrafficLevel.high;
    }

    if (hour >= 12 && hour <= 16) {
      return TrafficLevel.low;
    }

    if (hour >= 22 || hour <= 5) {
      return TrafficLevel.low;
    }

    return TrafficLevel.normal;
  }

  /// Get recent reports
  static List<Report> getRecentReports(List<Report> reports) {
    final now = DateTime.now();

    return reports
        .where((r) =>
    now.difference(r.createdAt).inMinutes <=
        _reportWindowMinutes)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Check official update
  static bool hasOfficialUpdate(List<Report> reports) {
    final now = DateTime.now();

    return reports.any((r) =>
    r.isVerified &&
        now.difference(r.createdAt).inMinutes <
            _officialWindowMinutes);
  }
}

class StationStatusResult {
  final TrafficLevel traffic;
  final bool isAvailable;
  final bool isOfficial;
  final int reportCount;
  final DateTime? lastUpdateTime;
  final int? freshnessMinutes;
  final double confidence;

  StationStatusResult({
    required this.traffic,
    required this.isAvailable,
    required this.isOfficial,
    required this.reportCount,
    this.lastUpdateTime,
    this.freshnessMinutes,
    this.confidence = 0,
  });

  @override
  String toString() {
    return 'StationStatusResult('
        'traffic: ${traffic.name}, '
        'isAvailable: $isAvailable, '
        'isOfficial: $isOfficial, '
        'reportCount: $reportCount, '
        'confidence: $confidence, '
        'freshness: $freshnessMinutes min'
        ')';
  }
}