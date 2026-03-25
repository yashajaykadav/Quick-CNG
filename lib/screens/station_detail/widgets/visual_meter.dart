import 'package:flutter/material.dart';
import '../../../models/enums.dart';

class VisualWaitMeter extends StatelessWidget {
  final TrafficLevel traffic;

  const VisualWaitMeter({super.key, required this.traffic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trafficInfo = _getTrafficInfo(traffic, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ Uses the Card Color (0xFF121212) from your theme
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        // ✅ AMOLED Depth: Subtle border using the status color
        border: Border.all(
          color: trafficInfo.color.withAlpha(isDark ? 40 : 50),
          width: 2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: trafficInfo.color.withAlpha(20),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: trafficInfo.bg,
              shape: BoxShape.circle,
            ),
            child: Icon(trafficInfo.icon, size: 36, color: trafficInfo.color),
          ),
          const SizedBox(width: 20),

          // Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Wait Time",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trafficInfo.title,
                  style: TextStyle(
                    color: trafficInfo.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trafficInfo.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, Color bg, String title, String subtitle, IconData icon})
  _getTrafficInfo(TrafficLevel traffic, bool isDark) {
    switch (traffic) {
      case TrafficLevel.low:
        return (
          color: isDark ? Colors.green[300]! : const Color(0xFF1FAF5A),
          bg: isDark
              ? Colors.green[900]!.withAlpha(100)
              : const Color(0xFFE8F8EF),
          title: 'Short Wait',
          subtitle: '0 to 10 minutes',
          icon: Icons.speed_rounded,
        );
      case TrafficLevel.normal:
        return (
          color: isDark ? Colors.orange[300]! : const Color(0xFFE07B00),
          bg: isDark
              ? Colors.orange[900]!.withAlpha(100)
              : const Color(0xFFFFF3E0),
          title: 'Moderate Wait',
          subtitle: '10 to 20 minutes',
          icon: Icons.hourglass_bottom_rounded,
        );
      case TrafficLevel.high:
        return (
          color: isDark ? Colors.red[300]! : const Color(0xFFD32F2F),
          bg: isDark
              ? Colors.red[900]!.withAlpha(100)
              : const Color(0xFFFFEBEE),
          icon: Icons.traffic_rounded,
          title: 'Long Queue',
          subtitle: 'Over 20 minutes',
        );
    }
  }
}
