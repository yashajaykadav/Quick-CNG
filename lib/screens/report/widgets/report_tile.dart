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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Traffic Icon with soft background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trafficColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getTrafficIcon(report.traffic),
                    color: trafficColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Traffic Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.traffic.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: trafficColor.withValues(alpha: 0.9),
                          fontSize: 17,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTimestamp(report.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Clean Availability Badge
                if (report.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Available",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 12),

            // User Info Section
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 14,
                  backgroundColor: report.isVerified 
                      ? Colors.blue.shade50 
                      : Colors.grey.shade100,
                  child: Icon(
                    report.isVerified ? _getRoleIcon(report.userRole) : Icons.person_outline,
                    size: 16,
                    color: report.isVerified ? Colors.blue.shade700 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 10),
                
                // User Name/Role
                Expanded(
                  child: Text(
                    report.isVerified 
                        ? '${report.userRole.displayName} Report'
                        : 'Reported by ${report.userName ?? "Anonymous"}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: report.isVerified ? FontWeight.w700 : FontWeight.w500,
                      color: report.isVerified ? Colors.blue.shade700 : Colors.grey.shade700,
                    ),
                  ),
                ),

                // Verification Badge
                if (report.isVerified)
                  Icon(Icons.verified_rounded, color: Colors.blue.shade600, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrafficIcon(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low:
        return Icons.speed_rounded;
      case TrafficLevel.normal:
        return Icons.schedule_rounded;
      case TrafficLevel.high:
        return Icons.traffic_rounded;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.owner:
        return Icons.store_rounded;
      case UserRole.worker:
        return Icons.work_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}