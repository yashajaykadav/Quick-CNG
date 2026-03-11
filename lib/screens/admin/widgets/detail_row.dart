import 'package:flutter/material.dart';

  Widget detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isLink = false,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isLink ? Colors.blue : (valueColor ?? Colors.black87),
                  fontWeight: isLink ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  decoration: isLink
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }