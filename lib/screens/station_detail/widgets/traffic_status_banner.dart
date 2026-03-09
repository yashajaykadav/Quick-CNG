import 'package:flutter/material.dart';
import 'package:quickcng/models/enums.dart';

class TrafficStatusBanner extends StatelessWidget {
  final TrafficLevel traffic;

  const TrafficStatusBanner({
    super.key,
    required this.traffic,
  });

  @override
  Widget build(BuildContext context) {
    final info = _getTrafficData(traffic);
    final trafficColor = info.color;

    int activeBars = traffic.index + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: trafficColor.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: trafficColor.withAlpha(50),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// LEFT SIDE
          Row(
            children: [
              Icon(info.icon, color: trafficColor, size: 30),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traffic.displayName.toUpperCase(),
                    style: TextStyle(
                      color: trafficColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  Text(
                    info.timeText,
                    style: TextStyle(
                      color: trafficColor.withAlpha(150),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// RIGHT SIDE BARS
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 12.0 + (index * 7),
                width: 9,
                decoration: BoxDecoration(
                  color: index < activeBars
                      ? trafficColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  _TrafficData _getTrafficData(TrafficLevel traffic) {
    switch (traffic) {
      case TrafficLevel.low:
        return const _TrafficData(
          color: Color(0xFF4CAF50),
          icon: Icons.bolt,
          timeText: '0–10 min',
        );

      case TrafficLevel.normal:
        return const _TrafficData(
          color: Color(0xFFFFA726),
          icon: Icons.access_time_filled,
          timeText: '10–20 min',
        );

      case TrafficLevel.high:
        return const _TrafficData(
          color: Color(0xFFEF5350),
          icon: Icons.block,
          timeText: '20+ min',
        );
    }
  }
}

class _TrafficData {
  final Color color;
  final IconData icon;
  final String timeText;

  const _TrafficData({
    required this.color,
    required this.icon,
    required this.timeText,
  });
}