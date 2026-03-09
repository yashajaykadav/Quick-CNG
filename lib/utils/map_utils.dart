import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  static Future<void> openMap(BuildContext context, double lat, double lng) async {
    // Note: Using a standard Google Maps URL scheme
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Maps')),
        );
      }
    }
  }
}