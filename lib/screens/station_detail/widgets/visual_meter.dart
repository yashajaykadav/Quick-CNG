import 'package:flutter/material.dart';
import '../../../models/enums.dart';

class VisualWaitMeter extends StatelessWidget {
  final TrafficLevel traffic;

  const VisualWaitMeter({
    super.key,
    required this.traffic,
  });

  @override
  Widget build(BuildContext context) {
    final trafficInfo = _getTrafficInfo(traffic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: trafficInfo.color.withAlpha(50), width: 2),
        boxShadow: [
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
                const Text(
                  "Current Wait Time",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                    fontSize: 13,
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
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 14,
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
      _getTrafficInfo(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low:
        return (
          color: const Color(0xFF1FAF5A),
          bg: const Color(0xFFE8F8EF),
          title: 'Short Wait',
          subtitle: '0 to 10 minutes',
          icon: Icons.speed_rounded,
        );
      case TrafficLevel.normal:
        return (
          color: const Color(0xFFE07B00),
          bg: const Color(0xFFFFF3E0),
          title: 'Moderate Wait',
          subtitle: '10 to 20 minutes',
          icon: Icons.hourglass_bottom_rounded,
        );
      case TrafficLevel.high:
        return (
          color: const Color(0xFFD32F2F),
          bg: const Color(0xFFFFEBEE),
          title: 'Long Queue',
          subtitle: 'Over 20 minutes',
          icon: Icons.traffic_rounded,
        );
    }
  }
}