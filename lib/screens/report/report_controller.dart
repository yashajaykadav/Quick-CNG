import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/models/user.dart';
import 'package:quickcng/providers/report_provider.dart';
import 'package:quickcng/providers/user_provider.dart';
import 'report_state.dart';

final reportControllerProvider =
    StateNotifierProvider.autoDispose<ReportController, ReportState>((ref) {
      return ReportController(ref);
    });

class ReportController extends StateNotifier<ReportState> {
  final Ref ref;
  ReportController(this.ref) : super(ReportState());

  void updateTraffic(TrafficLevel? t) =>
      state = state.copyWith(selectedTraffic: t);

  void updateAvailability(bool a) => state = state.copyWith(
    isAvailable: a,
    selectedTraffic: a ? state.selectedTraffic : null,
  );

  Future<void> submitReport({
    required Station station,
    required Function(String, {bool isError}) onNotify,
    required Future<bool> Function() onConfirm,
    required Future<bool> Function() onDistanceWarning,
    required Function() onSuccess,
  }) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final user = ref.read(currentUserProfileProvider);
      if (user == null || user.role == UserRole.guest) {
        throw 'Please login first';
      }

      // 1. Identify Privileged Users (Admin/Staff)
      final bool isPrivileged =
          user.isAdmin || (user.isStationStaff && user.stationId == station.id);

      // 2. Normal User Restrictions
      if (!isPrivileged) {
        if (_hasRecentReport(station.id, user.uid)) {
          throw 'You can only report once every 30 minutes.';
        }

        final position = await _determinePosition();
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          station.latitude,
          station.longitude,
        );

        if (distance > 500 && !await onDistanceWarning()) return;
        if (!await onConfirm()) return;
      }

      // 3. Execution: Submit to Worker
      // Note: Station update now happens automatically on the Backend!
      await _saveToDb(station, user, isPrivileged);

      onSuccess();
    } catch (e) {
      onNotify(e.toString(), isError: true);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  bool _hasRecentReport(String stationId, String userId) {
    final reports = ref.read(stationReportsProvider(stationId)).value ?? [];
    final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
    return reports.any(
      (r) => r.userId == userId && r.createdAt.isAfter(thirtyMinsAgo),
    );
  }

  Future<void> _saveToDb(
    Station station,
    AppUser user,
    bool isPrivileged,
  ) async {
    final report = Report(
      id: '',
      stationId: station.id,
      stationName: station.name,
      traffic: state.selectedTraffic ?? TrafficLevel.normal,
      isAvailable: state.isAvailable,
      createdAt: DateTime.now(),
      userId: user.uid,
      userName: user.name,
      userRole: isPrivileged ? user.role : UserRole.user,
    );

    // This triggers the POST to Cloudflare Worker
    await ref.read(submitReportProvider)(station.id, report);

    // Refresh local UI data
    ref.invalidate(stationReportsProvider(station.id));
  }

  Future<Position> _determinePosition() async {
    // Standard Geolocator logic...
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }
}
