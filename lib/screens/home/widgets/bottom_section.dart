import 'package:flutter/material.dart';

import '../../../models/station.dart';
import '../../../utils/helpers.dart' as helpers;
import '../../../utils/map_utils.dart';

class BottomSection extends StatelessWidget {
  final Station station;
  final VoidCallback onReport;

  const BottomSection({super.key,
    required this.station,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 15, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              "Updated ${helpers.formatTimestamp(station.updatedAt)}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: (station.latitude == 0.0 && station.longitude == 0.0)
              ? null
              : () => MapUtils.openMap(context, station.latitude, station.longitude),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1FAF5A), Color(0xFF0E8E46)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.navigation, size: 16, color: Colors.white),
                SizedBox(width: 6),
                // Text(
                //   "Navigate",
                //   style: TextStyle(
                //     fontSize: 13,
                //     fontWeight: FontWeight.w600,
                //     color: Colors.white,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}