import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/station.dart';
import '../../../utils/map_utils.dart';

class AddressSection extends StatelessWidget {
  final Station station;

  const AddressSection({super.key, required this.station});

  Future<void> _openInMaps(BuildContext context) async {
    try {
      if (station.latitude != 0.0 && station.longitude != 0.0) {
        MapUtils.openMap(context, station.latitude, station.longitude);
        return;
      }
    } catch (_) {}

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ Uses the Card Color (0xFF121212) from main.dart
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        // ✅ AMOLED Depth: Subtle border instead of shadow
        border: isDark
            ? Border.all(color: Colors.white.withAlpha(20), width: 1)
            : Border.all(color: Colors.black.withAlpha(5), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Station Location",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue[900]!.withAlpha(80)
                      : Colors.blue.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: isDark ? Colors.blue[300] : Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  station.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(200),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInMaps(context),
              icon: const Icon(Icons.near_me_rounded),
              label: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}
