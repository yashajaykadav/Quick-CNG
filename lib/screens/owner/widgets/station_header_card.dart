import 'package:flutter/material.dart';
import 'package:quickcng/models/enums.dart';

class StationHeaderCard extends StatelessWidget {
  final String name;
  final StationStatus status;
  final TrafficLevel traffic;

  const StationHeaderCard({
    super.key,
    required this.name,
    required this.status,
    required this.traffic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[700]!, Colors.green[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_gas_station,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatusChip(
                  label: status.displayName,
                  color: _getStatusColor(status),
                  icon: _getStatusIcon(status),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: traffic.shortName,
                  color: traffic.color,
                  icon: Icons.traffic,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return Colors.white;
      case StationStatus.unavailable:
        return Colors.red[100]!;
      case StationStatus.closed:
        return Colors.grey[300]!;
    }
  }

  IconData _getStatusIcon(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return Icons.check_circle;
      case StationStatus.unavailable:
        return Icons.cancel;
      case StationStatus.closed:
        return Icons.do_not_disturb;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
