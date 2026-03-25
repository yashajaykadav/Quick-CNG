import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final List<Widget> children;

  const MenuCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Pulls from CardThemeData in main.dart
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        // Subtle border for AMOLED definition
        border: isDark
            ? Border.all(color: Colors.white.withAlpha(20), width: 1)
            : Border.all(color: theme.dividerColor.withAlpha(10), width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}
