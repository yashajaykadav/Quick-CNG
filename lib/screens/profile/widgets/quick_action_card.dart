import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ Uses the Card color (0xFF121212) from our Theme configuration
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          // ✅ AMOLED Depth: Use a subtle border instead of shadows
          border: isDark
              ? Border.all(color: Colors.white.withAlpha(15), width: 1)
              : Border.all(color: Colors.black.withAlpha(5), width: 1),
          boxShadow: isDark
              ? null // No shadows on pure black backgrounds
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ✅ Brighter tint for dark mode icons
                color: isDark ? color.withAlpha(40) : color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark
                    ? color.withAlpha(220)
                    : color, // Pop color slightly more in dark mode
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                // ✅ Use onSurface to ensure perfect white/black contrast
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
