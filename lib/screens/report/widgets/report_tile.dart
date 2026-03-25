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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use slightly brighter colors for dark mode visibility
    final trafficColor = isDark ? _getDarkTrafficColor(report.traffic) : report.traffic.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ✅ Adaptive Background (Uses 0xFF121212 from your main.dart)
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        // ✅ Subtle border for AMOLED depth
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.grey.shade100, 
          width: 1.5
        ),
        boxShadow: isDark ? [] : [
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
                // Traffic Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trafficColor.withValues(alpha: isDark ? 0.15 : 0.1),
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
                          color: trafficColor,
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
                          color: theme.hintColor, // ✅ Adaptive text color
                        ),
                      ),
                    ],
                  ),
                ),

                // Clean Availability Badge
                if (report.isAvailable) _buildAvailabilityBadge(isDark),
              ],
            ),
            
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? Colors.white.withAlpha(20) : Colors.grey.shade100),
            const SizedBox(height: 12),

            // User Info Section
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: report.isVerified 
                      ? (isDark ? Colors.blue.withAlpha(40) : Colors.blue.shade50)
                      : (isDark ? Colors.white.withAlpha(20) : Colors.grey.shade100),
                  child: Icon(
                    report.isVerified ? _getRoleIcon(report.userRole) : Icons.person_outline,
                    size: 16,
                    color: report.isVerified 
                        ? (isDark ? Colors.blue[300] : Colors.blue.shade700) 
                        : (isDark ? Colors.grey[400] : Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 10),
                
                Expanded(
                  child: Text(
                    report.isVerified 
                        ? '${report.userRole.displayName} Report'
                        : 'Reported by ${report.userName ?? "Anonymous"}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: report.isVerified ? FontWeight.w700 : FontWeight.w500,
                      color: report.isVerified 
                          ? (isDark ? Colors.blue[300] : Colors.blue.shade700) 
                          : theme.hintColor,
                    ),
                  ),
                ),

                if (report.isVerified)
                  Icon(Icons.verified_rounded, color: isDark ? Colors.blue[400] : Colors.blue.shade600, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.green[900]!.withAlpha(80) : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.green[800]!.withAlpha(150) : Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: isDark ? Colors.green[300] : Colors.green.shade600, size: 14),
          const SizedBox(width: 4),
          Text(
            "Available",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.green[300] : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDarkTrafficColor(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low: return Colors.green[300]!;
      case TrafficLevel.normal: return Colors.orange[300]!;
      case TrafficLevel.high: return Colors.red[300]!;
    }
  }

  IconData _getTrafficIcon(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low: return Icons.speed_rounded;
      case TrafficLevel.normal: return Icons.schedule_rounded;
      case TrafficLevel.high: return Icons.traffic_rounded;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin: return Icons.admin_panel_settings_rounded;
      case UserRole.owner: return Icons.store_rounded;
      case UserRole.worker: return Icons.work_rounded;
      default: return Icons.person_rounded;
    }
  }
}