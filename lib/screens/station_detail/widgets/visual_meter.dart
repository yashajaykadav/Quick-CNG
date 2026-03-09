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
    final color = traffic.color;
    final bars = traffic.index + 1;

    final label = switch (traffic) {
      TrafficLevel.low => "🚀 FAST",
      TrafficLevel.normal => "⏳ BUSY",
      TrafficLevel.high => "🚫 LONG WAIT",
    };

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "CURRENT LINE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 20 + (i * 10),
                width: 25,
                decoration: BoxDecoration(
                  color: i < bars ? color : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}