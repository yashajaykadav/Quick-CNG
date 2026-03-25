import 'package:flutter/material.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/models/enums.dart';

class HeaderCard extends StatelessWidget {
  final Station station;

  const HeaderCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusInfo = _getStatusInfo(station.status, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ Uses the Card Color (0xFF121212) from main.dart
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        // ✅ AMOLED Depth: Subtle border for definition
        border: isDark
            ? Border.all(color: Colors.white.withAlpha(20), width: 1)
            : Border.all(color: Colors.black.withAlpha(5), width: 1),
        boxShadow: isDark
            ? []
            : [
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
                    fontWeight: FontWeight.bold,
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
              if (station.distance != null) ...[
                const SizedBox(width: 12),
                _buildDistanceBadge(station.distance!, isDark),
              ],
            ],
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: theme.dividerColor.withAlpha(isDark ? 50 : 255),
          ),
          const SizedBox(height: 12),

          /// OFFICIAL UPDATE WARNING
          if (station.hasOfficialUpdate) ...[
            _buildOfficialUpdateBanner(isDark),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDistanceBadge(double distance, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green[900]!.withAlpha(80)
            : const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            distance.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.green[300] : const Color(0xFF1FAF5A),
            ),
          ),
          Text(
            'km',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.green[300] : const Color(0xFF1FAF5A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialUpdateBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue[900]!.withAlpha(40)
            : Colors.blue.withAlpha(20),
        border: Border.all(color: Colors.blue.withAlpha(isDark ? 80 : 80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: isDark ? Colors.blue[300] : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Official station update available below",
              style: TextStyle(
                color: isDark ? Colors.blue[200] : Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, Color bg, IconData icon, String label}) _getStatusInfo(
    StationStatus status,
    bool isDark,
  ) {
    switch (status) {
      case StationStatus.available:
        return (
          color: isDark ? Colors.green[300]! : const Color(0xFF1FAF5A),
          bg: isDark
              ? Colors.green[900]!.withAlpha(100)
              : const Color(0xFFE8F8EF),
          icon: Icons.check_circle,
          label: 'CNG Available',
        );
      case StationStatus.unavailable:
        return (
          color: isDark ? Colors.orange[300]! : const Color(0xFFE07B00),
          bg: isDark
              ? Colors.orange[900]!.withAlpha(100)
              : const Color(0xFFFFF3E0),
          icon: Icons.warning_rounded,
          label: 'Currently Unavailable',
        );
      case StationStatus.closed:
        return (
          color: isDark ? Colors.red[300]! : const Color(0xFFD32F2F),
          bg: isDark
              ? Colors.red[900]!.withAlpha(100)
              : const Color(0xFFFFEBEE),
          icon: Icons.cancel,
          label: 'Station Closed',
        );
    }
  }
}
