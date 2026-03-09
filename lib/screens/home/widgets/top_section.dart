import 'package:flutter/material.dart';
import 'package:quickcng/models/station.dart';
import '../../../models/enums.dart';

class TopSection extends StatelessWidget {
  final Station station;

  const TopSection({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(station.status);
    final trafficColor = _getTrafficColor(station.traffic);

    return Row(
      children: [
        // STATUS CIRCLE
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 3),
          ),
          child: Icon(
            _getStatusIcon(station.status),
            color: statusColor,
            size: 30,
          ),
        ),

        const SizedBox(width: 12),

        // STATION INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              Text(
                "📍 ${station.distance?.toStringAsFixed(1) ?? '0'} km",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        _buildTrafficBars(station.traffic, trafficColor),
      ],
    );
  }

  Widget _buildTrafficBars(TrafficLevel level, Color color) {
    int barCount = (level == TrafficLevel.low)
        ? 1
        : (level == TrafficLevel.normal ? 2 : 3);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 8,
              height: 12.0 + (i * 6),
              decoration: BoxDecoration(
                color: i < barCount ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),

        const SizedBox(height: 4),

        const Icon(Icons.access_time, size: 14, color: Colors.grey),
      ],
    );
  }

  Color _getStatusColor(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return Colors.green;
      case StationStatus.unavailable:
        return Colors.orange;
      case StationStatus.closed:
        return Colors.red;
    }
  }

  Color _getTrafficColor(TrafficLevel level) {
    switch (level) {
      case TrafficLevel.low:
        return Colors.green;
      case TrafficLevel.normal:
        return Colors.orange;
      case TrafficLevel.high:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return Icons.check;
      case StationStatus.unavailable:
        return Icons.priority_high;
      case StationStatus.closed:
        return Icons.close;
    }
  }
}
