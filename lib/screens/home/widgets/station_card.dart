import 'package:flutter/material.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/utils/helpers.dart' as helpers;
import 'package:quickcng/utils/map_utils.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  final VoidCallback onReport;

  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(station.status);
    final trafficInfo = _getTrafficInfo(station.traffic);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ── TOP: Status banner + station name ──
              _StatusBanner(statusInfo: statusInfo),
              const SizedBox(height: 12),

              /// ── STATION NAME + DISTANCE ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Color(0xFF888888)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${station.city}, ${station.district}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888888),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Distance badge
                  if (station.distance != null)
                    _DistanceBadge(distance: station.distance!),
                ],
              ),

              const SizedBox(height: 14),

              /// ── TRAFFIC + 24H INFO ROW ──
              Row(
                children: [
                  _TrafficPill(trafficInfo: trafficInfo),
                  const SizedBox(width: 8),
                  if (station.is24Hours)
                    _InfoPill(
                      icon: Icons.access_time_filled,
                      label: 'Open 24 Hours',
                      color: const Color(0xFF1FAF5A),
                    ),
                ],
              ),

              /// ── BADGES ──
              if (station.hasOfficialUpdate) ...[
                const SizedBox(height: 10),
                _UpdateBadge(
                  icon: Icons.verified_user,
                  label: 'Verified staff update',
                  color: Colors.blue,
                ),
              ] else if (station.reportCount > 0) ...[
                const SizedBox(height: 10),
                _UpdateBadge(
                  icon: Icons.people,
                  label: '${station.reportCount} community report${station.reportCount > 1 ? 's' : ''}',
                  color: Colors.blueGrey,
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),

              /// ── BOTTOM ACTIONS ──
              Row(
                children: [
                  // Updated time
                  Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    helpers.formatTimestamp(station.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  const Spacer(),

                  // Report button
                  _ActionButton(
                    icon: Icons.edit_note,
                    label: 'Report',
                    color: Colors.orange.shade700,
                    bgColor: Colors.orange.withAlpha(18),
                    onTap: onReport,
                  ),

                  const SizedBox(width: 8),

                  // Navigate button
                  _ActionButton(
                    icon: Icons.near_me,
                    label: 'Navigate',
                    color: Colors.white,
                    bgColor: const Color(0xFF1FAF5A),
                    onTap: (station.latitude == 0.0 && station.longitude == 0.0)
                        ? null
                        : () => MapUtils.openMap(
                              context,
                              station.latitude,
                              station.longitude,
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

  // ── Helpers ──

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

  ({Color color, String label, IconData icon}) _getTrafficInfo(
      TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low:
        return (
          color: const Color(0xFF1FAF5A),
          label: 'Low Wait',
          icon: Icons.directions_car,
        );
      case TrafficLevel.normal:
        return (
          color: const Color(0xFFE07B00),
          label: 'Moderate Wait',
          icon: Icons.directions_car,
        );
      case TrafficLevel.high:
        return (
          color: const Color(0xFFD32F2F),
          label: 'Long Queue',
          icon: Icons.directions_car,
        );
    }
  }
}

// ── Sub-widgets ──

class _StatusBanner extends StatelessWidget {
  final ({Color color, Color bg, IconData icon, String label}) statusInfo;
  const _StatusBanner({required this.statusInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  final double distance;
  const _DistanceBadge({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            distance.toStringAsFixed(1),
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
    );
  }
}

class _TrafficPill extends StatelessWidget {
  final ({Color color, String label, IconData icon}) trafficInfo;
  const _TrafficPill({required this.trafficInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: trafficInfo.color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: trafficInfo.color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trafficInfo.icon, size: 13, color: trafficInfo.color),
          const SizedBox(width: 5),
          Text(
            trafficInfo.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: trafficInfo.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _UpdateBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
