import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/providers/user_provider.dart';
import 'package:quickcng/providers/report_provider.dart';
import 'package:quickcng/screens/report/widgets/traffic_option.dart';

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
    if (selectedTraffic == null) {
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

      final isStaff = userProfile.isStationStaff;

      // Check 30-minute cooldown
      if (!isStaff) {
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
      if (!isStaff) {
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
      await _saveReport(userProfile);
      final stationService = StationService();
      await stationService.updateStationStatus(widget.station.id);

      if (mounted) {
        _showSnackBar(
          isStaff ? 'Official Status Updated' : 'Report Submitted',
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

  Future<void> _saveReport(AppUser user) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1. Add report to station's reports subcollection
    final reportRef = firestore
        .collection('cng_stations')
        .doc(widget.station.id)
        .collection('reports')
        .doc();

    batch.set(reportRef, {
      'traffic': selectedTraffic!.name,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'userName': user.name,
      'userRole': user.role.name,
    });

    // 2. Update station's aggregated data
    final stationRef = firestore
        .collection('cng_stations')
        .doc(widget.station.id);

    batch.update(stationRef, {
      'traffic': selectedTraffic!.name,
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
            const Text(
              'Select Current Queue Status',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // Traffic options
            TrafficOption(
              label: 'Low Traffic (0-10 min)',
              color: Colors.green,
              icon: Icons.sentiment_satisfied,
              isSelected: selectedTraffic == TrafficLevel.low,
              onTap: () => setState(() => selectedTraffic = TrafficLevel.low),
            ),
            TrafficOption(
              label: 'Normal Traffic (10-20 min)',
              color: Colors.orange,
              icon: Icons.sentiment_neutral,
              isSelected: selectedTraffic == TrafficLevel.normal,
              onTap: () => setState(() => selectedTraffic = TrafficLevel.normal),
            ),
            TrafficOption(
              label: 'High Traffic (20+ min)',
              color: Colors.red,
              icon: Icons.sentiment_dissatisfied,
              isSelected: selectedTraffic == TrafficLevel.high,
              onTap: () => setState(() => selectedTraffic = TrafficLevel.high),
            ),

            const SizedBox(height: 30),

            // CNG Availability
            const Text(
              'CNG Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _AvailabilityButton(
                    label: 'Available',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isSelected: isAvailable,
                    onTap: () => setState(() => isAvailable = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AvailabilityButton(
                    label: 'Not Available',
                    icon: Icons.cancel,
                    color: Colors.red,
                    isSelected: !isAvailable,
                    onTap: () => setState(() => isAvailable = false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (isSubmitting || selectedTraffic == null)
                    ? null
                    : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Submit Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Report'),
        content: Text(
          'Queue: ${selectedTraffic?.displayName}\n'
              'Availability: ${isAvailable ? "Available" : "Not Available"}',
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
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }
}

// Availability Button Widget
class _AvailabilityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvailabilityButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}