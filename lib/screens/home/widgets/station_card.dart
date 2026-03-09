import 'package:flutter/material.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/screens/home/widgets/top_section.dart';
import 'package:quickcng/screens/home/widgets/bottom_section.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  final VoidCallback onReport;

  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 13),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP SECTION
            TopSection(station: station),

            /// BADGES
            if (station.hasOfficialUpdate)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _OfficialUpdateBadge(station: station),
              )
            else if (station.reportCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _CommunityReportBadge(station: station),
              ),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),

            /// BOTTOM ACTIONS
            BottomSection(station: station, onReport: onReport),
          ],
        ),
      ),
    );
  }
}

/// Official Update Badge
class _OfficialUpdateBadge extends StatelessWidget {
  final Station station;

  const _OfficialUpdateBadge({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withAlpha(45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 16, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            'Official Update: ${station.traffic.shortName} Rush',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Community Reports Badge
class _CommunityReportBadge extends StatelessWidget {
  final Station station;

  const _CommunityReportBadge({required this.station});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.people_outline, size: 14, color: Colors.blueGrey[400]),
        const SizedBox(width: 6),
        Text(
          'Community: ${station.traffic.shortName} (${station.reportCount} reports)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
