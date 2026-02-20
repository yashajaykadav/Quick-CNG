import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/station.dart';
import '../providers/home_provider.dart';
import 'station_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'report_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Color _getTrafficColor(String traffic) {
    switch (traffic.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'normal':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }



  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.check_circle;
      case 'closed':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_gas_station, color: Colors.white),
            SizedBox(width: 8),
            Text('Quick CNG'),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Stations auto-update via stream, but this is a visual cue
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stations update in real-time!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: stations.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Loading stations...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return _StationCard(
                  station: station,
                  trafficColor: _getTrafficColor(station.traffic),
                  statusIcon: _getStatusIcon(station.status),
                  statusColor: _getStatusColor(station.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StationDetailScreen(stationId: station.id),
                      ),
                    );
                  },
                  onReport: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportScreen(station: station),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final Station station;
  final Color trafficColor;
  final IconData statusIcon;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onReport;

  const _StationCard({
    required this.station,
    required this.trafficColor,
    required this.statusIcon,
    required this.statusColor,
    required this.onTap,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Station Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_gas_station,
                      color: Colors.green[700],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              station.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Traffic Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: trafficColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: trafficColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.traffic, size: 16, color: trafficColor),
                        const SizedBox(width: 4),
                        Text(
                          station.traffic,
                          style: TextStyle(
                            color: trafficColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Bottom Row
              Row(
  children: [
    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
    const SizedBox(width: 4),
    Text(
      'Updated: ${_formatTime(station.updatedAt)}',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    ),
    const Spacer(),
    SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: (station.lat == 0.0 && station.lng == 0.0)
    ? null
    : () => _openMap(context,station.lat, station.lng),
        icon: const Icon(Icons.navigation, size: 16),
        label: const Text(
          'Navigate',
          style: TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    ),
  ],
),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
Future<void> _openMap(BuildContext context, double lat, double lng) async {
  final Uri googleMapsUrl = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
  );

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    );
  } else {
    // show snackbar in the same context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Maps')),
    );
  }
}