import 'package:flutter/material.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/models/enums.dart';

class HeaderCard extends StatelessWidget {
  final Station station;

  const HeaderCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(station.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// STATUS + DISTANCE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_statusBadge(), _distanceBadge()],
          ),

          const SizedBox(height: 18),

          /// STATION NAME
          Text(
            station.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          /// FULL ADDRESS
          Text(
            station.fullAddress,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 18),

          /// QUICK INFO ROW
          Row(
            children: [
              /// TRAFFIC LEVEL
              _infoItem(Icons.traffic, station.traffic.name.toUpperCase()),

              const SizedBox(width: 20),

              /// 24 HOURS
              if (station.is24Hours) _infoItem(Icons.access_time, "24 HOURS"),

              const SizedBox(width: 20),

              /// REPORT COUNT
              _infoItem(Icons.people, "${station.reportCount} REPORTS"),
            ],
          ),

          const SizedBox(height: 18),

          /// UPDATE INFO
          if (station.hasOfficialUpdate)
            const Text(
              "Official update available",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 22),
        ],
      ),
    );
  }

  /// STATUS BADGE
  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        station.displayStatus.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// DISTANCE BADGE
  Widget _distanceBadge() {
    final distanceText = station.distance != null
        ? "${station.distance!.toStringAsFixed(1)} KM"
        : "DISTANCE N/A";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(distanceText, style: const TextStyle(color: Colors.white)),
    );
  }

  /// INFO ITEM
  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return const Color(0xFF2E7D32);
      case StationStatus.unavailable:
        return const Color(0xFFD32F2F);
      case StationStatus.closed:
        return const Color(0xFF616161);
    }
  }
}
