import 'package:flutter/material.dart';
import '../../../models/enums.dart';
import 'traffic_option.dart';

class TrafficSelector extends StatelessWidget {
  final TrafficLevel? selectedTraffic;
  final ValueChanged<TrafficLevel> onTrafficSelected;

  const TrafficSelector({
    super.key,
    required this.selectedTraffic,
    required this.onTrafficSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Current Queue Status',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 25),
        TrafficOption(
          label: 'Low Traffic (0-10 min)',
          color: Colors.green,
          icon: Icons.sentiment_satisfied,
          isSelected: selectedTraffic == TrafficLevel.low,
          onTap: () => onTrafficSelected(TrafficLevel.low),
        ),
        TrafficOption(
          label: 'Normal Traffic (10-20 min)',
          color: Colors.orange,
          icon: Icons.sentiment_neutral,
          isSelected: selectedTraffic == TrafficLevel.normal,
          onTap: () => onTrafficSelected(TrafficLevel.normal),
        ),
        TrafficOption(
          label: 'High Traffic (20+ min)',
          color: Colors.red,
          icon: Icons.sentiment_dissatisfied,
          isSelected: selectedTraffic == TrafficLevel.high,
          onTap: () => onTrafficSelected(TrafficLevel.high),
        ),
      ],
    );
  }
}
