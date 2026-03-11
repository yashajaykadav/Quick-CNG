import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/station.dart';
import '../../../utils/map_utils.dart'; // We'll use this if available, or fallback

class AddressSection extends StatelessWidget {
  final Station station;

  const AddressSection({super.key, required this.station});

  Future<void> _openInMaps(BuildContext context) async {
    // Try MapUtils if available, else fallback
    try {
      if (station.latitude != 0.0 && station.longitude != 0.0) {
        MapUtils.openMap(context, station.latitude, station.longitude);
        return;
      }
    } catch (_) {}

    // Fallback exactly as it was
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
      "&destination=${station.latitude},${station.longitude}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Station Location",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          // Address info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  station.address,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Wide navigate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInMaps(context),
              icon: const Icon(Icons.near_me_rounded),
              label: const Text(
                'Get Directions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1FAF5A), // Green action button
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}