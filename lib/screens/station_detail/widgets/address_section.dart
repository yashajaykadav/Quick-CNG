import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/station.dart';

class AddressSection extends StatelessWidget {
  final Station station;

  const AddressSection({super.key, required this.station});

  Future<void> _openInMaps() async {
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _openInMaps,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Map pin icon in a coloured circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.green[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Address text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Station Location",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        station.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // "Tap to navigate" hint instead of coordinates
                      Row(
                        children: [
                          Icon(
                            Icons.directions_rounded,
                            size: 14,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Tap to open directions",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}