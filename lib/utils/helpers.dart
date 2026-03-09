import 'package:flutter/material.dart';

/// Convert hex string to Color
Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Format distance
String formatDistance(double? distance) {
  if (distance == null) return 'Calculating...';
  if (distance < 1) {
    return '${(distance * 1000).toStringAsFixed(0)} m';
  }
  return '${distance.toStringAsFixed(1)} km';
}

/// Format timestamp to relative time
String formatTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}