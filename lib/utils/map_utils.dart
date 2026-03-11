import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  static Future<void> openMap(BuildContext context, double lat, double lng) async {
    Uri mapUri;

    if (Platform.isAndroid) {
      // "geo:" triggers the Android Intent system to find a map app directly
      mapUri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    } else {
      // "comgooglemaps://" forces the Google Maps app on iOS if installed
      mapUri = Uri.parse("comgooglemaps://?q=$lat,$lng");
    }

    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri);
      } else {
        // Fallback for iOS if Google Maps app is not installed
        if (Platform.isIOS) {
          await launchUrl(Uri.parse("https://maps.apple.com/?q=$lat,$lng"));
        } else {
          throw 'Could not launch maps';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Maps App')),
        );
      }
    }
  }
}
