import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Icon background and foreground
    final iconBg = isDark ? Colors.grey[700]?.withAlpha(20) : Colors.grey[100];
    final iconColor = isDark ? Colors.grey[300] : Colors.grey[700];

    // Subtitle color
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    // Trailing icon
    final trailingIconColor = isDark ? Colors.grey[500] : Colors.grey[400];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: subtitleColor,
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: trailingIconColor),
      onTap: onTap,
    );
  }
}
