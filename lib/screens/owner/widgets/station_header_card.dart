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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ AMOLED Gradient: Pure Black to Deep Grey
    final gradientColors = isDark
        ? [Colors.black, const Color(0xFF1A1A1A)]
        : [Colors.green[700]!, Colors.green[500]!];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        // ✅ Subtle border for AMOLED definition
        border: isDark
            ? Border.all(color: Colors.white.withAlpha(20), width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_gas_station,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatusChip(
                label: status.displayName,
                color: _getStatusColor(status, isDark),
                icon: _getStatusIcon(status),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                label: traffic.shortName,
                color: traffic.color, // Assumes traffic.color handles itself
                icon: Icons.traffic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StationStatus status, bool isDark) {
    switch (status) {
      case StationStatus.available:
        return isDark ? Colors.green[300]! : Colors.white;
      case StationStatus.unavailable:
        return isDark ? Colors.orange[300]! : Colors.orange[100]!;
      case StationStatus.closed:
        return isDark ? Colors.red[300]! : Colors.red[100]!;
    }
  }

  IconData _getStatusIcon(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return Icons.check_circle;
      case StationStatus.unavailable:
        return Icons.warning_amber_rounded;
      case StationStatus.closed:
        return Icons.cancel_outlined;
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
