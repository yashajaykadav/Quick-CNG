import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/providers/user_provider.dart';
import 'package:quickcng/providers/report_provider.dart';
import 'package:quickcng/screens/report/widgets/availability_button.dart';
import 'package:quickcng/screens/report/widgets/report_submit_button.dart';
import 'package:quickcng/screens/report/widgets/traffic_selector.dart';

import '../../models/user.dart';
import '../../services/station_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final Station station;

  const ReportScreen({
    super.key,
    required this.station,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  TrafficLevel? selectedTraffic;
  bool isAvailable = true;
  bool isSubmitting = false;

  Future<void> _submitReport() async {
    if (isAvailable && selectedTraffic == null) {
      _showSnackBar('Please select queue status');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Get current user profile
      final userProfile = ref.read(currentUserProfileProvider);

      if (userProfile == null || userProfile.role == UserRole.guest) {
        _showSnackBar('Please login to submit reports');
        setState(() => isSubmitting = false);
        return;
      }

      final isStaffForThisStation = userProfile.isAdmin || 
          (userProfile.isStationStaff && userProfile.stationId == widget.station.id);

      // Check 30-minute cooldown
      if (!isStaffForThisStation) {
        final recentReports = ref.read(stationReportsProvider(widget.station.id)).value ?? [];
        final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
        
        final hasRecentReport = recentReports.any((report) => 
            report.userId == userProfile.uid && 
            report.createdAt.isAfter(thirtyMinsAgo));

        if (hasRecentReport) {
          _showSnackBar('You can only report once every 30 minutes for this station.');
          setState(() => isSubmitting = false);
          return;
        }
      }

      // Distance check for non-staff users
      if (!isStaffForThisStation) {
        final position = await _determinePosition();
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          widget.station.latitude,
          widget.station.longitude,
        );

        if (distance > 500) {
          final proceed = await _showDistanceWarning();
          if (!proceed) {
            setState(() => isSubmitting = false);
            return;
          }
        }

        // Confirmation dialog for regular users
        final confirmed = await _showConfirmDialog();
        if (!confirmed) {
          setState(() => isSubmitting = false);
          return;
        }
      }

      // Submit report to Firestore
      await _saveReport(userProfile, isStaffForThisStation);
      final stationService = StationService();
      await stationService.updateStationStatus(widget.station.id);

      if (mounted) {
        _showSnackBar(
          isStaffForThisStation ? 'Official Status Updated' : 'Report Submitted',
          isSuccess: true,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _saveReport(AppUser user, bool isStaffForThisStation) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1. Add report to station's reports subcollection
    final reportRef = firestore
        .collection('cng_stations')
        .doc(widget.station.id)
        .collection('reports')
        .doc();

    batch.set(reportRef, {
      'traffic': (selectedTraffic ?? TrafficLevel.normal).name,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'userName': user.name,
      'userRole': (isStaffForThisStation ? user.role : UserRole.user).name,
    });

    // 2. Update station's aggregated data
    final stationRef = firestore
        .collection('cng_stations')
        .doc(widget.station.id);

    batch.update(stationRef, {
      'traffic': (selectedTraffic ?? TrafficLevel.normal).name,
      'status': isAvailable ? StationStatus.available.name : StationStatus.unavailable.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'reportCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Status'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station name
            Text(
              widget.station.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            const SizedBox(height: 15),

            // CNG Availability
            const Text(
              'CNG Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: AvailabilityButton(
                    label: 'Available',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isSelected: isAvailable,
                    onTap: () => setState(() => isAvailable = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AvailabilityButton(
                    label: 'Not Available',
                    icon: Icons.cancel,
                    color: Colors.red,
                    isSelected: !isAvailable,
                    onTap: () {
                       setState(() {
                         isAvailable = false;
                         selectedTraffic = null;
                       });
                    },
                  ),
                ),
              ],
            ),

            if (isAvailable) ...[
              const SizedBox(height: 30),
              // Traffic Selector
              TrafficSelector(
                selectedTraffic: selectedTraffic,
                onTrafficSelected: (traffic) => setState(() => selectedTraffic = traffic),
              ),
            ],

            const SizedBox(height: 40),

            // Submit button
            ReportSubmitButton(
              isSubmitting: isSubmitting,
              isDisabled: isAvailable && selectedTraffic == null,
              onPressed: _submitReport,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
            ? Colors.green
            : null,
      ),
    );
  }

  Future<bool> _showConfirmDialog() async {
    final queueText = isAvailable ? 'Queue: ${selectedTraffic?.displayName}\n' : '';
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Report'),
        content: Text(
          'Availability: ${isAvailable ? "Available" : "Not Available"}\n$queueText',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _showDistanceWarning() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Warning'),
        content: const Text(
          'You appear far from this station. Are you sure you want to report?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Please turn ON location services');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 10),
  ),
);
  }
}