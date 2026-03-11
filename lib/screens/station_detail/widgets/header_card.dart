import 'package:flutter/material.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/models/enums.dart';

class HeaderCard extends StatelessWidget {
  final Station station;

  const HeaderCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(station.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// STATUS BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusInfo.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(statusInfo.icon, size: 22, color: statusInfo.color),
                const SizedBox(width: 10),
                Text(
                  statusInfo.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: statusInfo.color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// STATION NAME & DISTANCE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  station.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
              ),
              if (station.distance != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8EF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${station.distance!.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1FAF5A),
                        ),
                      ),
                      const Text(
                        'km',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1FAF5A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          /// OFFICIAL UPDATE WARNING
          if (station.hasOfficialUpdate) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                border: Border.all(color: Colors.blue.withAlpha(80)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Official station update available below",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  ({Color color, Color bg, IconData icon, String label}) _getStatusInfo(
      StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return (
          color: const Color(0xFF1FAF5A),
          bg: const Color(0xFFE8F8EF),
          icon: Icons.check_circle,
          label: 'CNG Available',
        );
      case StationStatus.unavailable:
        return (
          color: const Color(0xFFE07B00),
          bg: const Color(0xFFFFF3E0),
          icon: Icons.warning_rounded,
          label: 'Currently Unavailable',
        );
      case StationStatus.closed:
        return (
          color: const Color(0xFFD32F2F),
          bg: const Color(0xFFFFEBEE),
          icon: Icons.cancel,
          label: 'Station Closed',
        );
    }
  }
}
