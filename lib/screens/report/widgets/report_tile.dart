import 'package:flutter/material.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/models/enums.dart';
import 'package:quickcng/utils/helpers.dart';

class ReportTile extends StatelessWidget {
  final Report report;

  const ReportTile({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final trafficColor = report.traffic.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Traffic icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: trafficColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTrafficIcon(report.traffic),
                  color: trafficColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Traffic level and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.traffic.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: trafficColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTimestamp(report.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Availability indicator
              Icon(
                report.isAvailable ? Icons.check_circle : Icons.cancel,
                color: report.isAvailable ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),

          // User badge (if verified)
          if (report.isVerified) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(report.userRole),
                    size: 14,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${report.userRole.displayName} Report',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ]
          // Regular user badge (optional)
          else if (report.userName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  'Reported by ${report.userName}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getTrafficIcon(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low:
        return Icons.speed;
      case TrafficLevel.normal:
        return Icons.schedule;
      case TrafficLevel.high:
        return Icons.traffic;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.owner:
        return Icons.store;
      case UserRole.worker:
        return Icons.work;
      default:
        return Icons.person;
    }
  }
}