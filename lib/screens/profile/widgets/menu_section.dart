import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/screens/profile/widgets/status_badge.dart';
import '../../../models/enums.dart';
import '../../../models/user.dart';
import 'menu_card.dart';
import 'menu_item.dart';

Widget buildMenuSection(BuildContext context, AppUser? user) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // ✅ Use onSurface for text to ensure perfect contrast in both modes
  final headerStyle = theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: theme.colorScheme.onSurface,
  );

  // ✅ Adaptive Divider Color
  final dividerColor = isDark
      ? Colors.white.withAlpha(20) // Subtle white for AMOLED
      : theme.dividerColor.withAlpha(50);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionLabel('Account', headerStyle),
      const SizedBox(height: 12),
      MenuCard(
        children: [
          MenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () => context.pushNamed('edit-profile'),
          ),
          Divider(height: 1, color: dividerColor, indent: 55),
          MenuItem(
            icon: Icons.assignment_outlined,
            title: 'My Reports',
            subtitle: 'View your submitted reports',
            onTap: () => context.pushNamed('my-reports'),
          ),
          if (user?.role == UserRole.user || user?.role == UserRole.guest) ...[
            Divider(height: 1, color: dividerColor, indent: 55),
            MenuItem(
              icon: Icons.verified_outlined,
              title: 'Verification Status',
              subtitle: 'Check your verification request',
              trailing: StatusBadge(
                text: 'Not Verified',
                // ✅ Refined orange for AMOLED
                color: isDark ? Colors.orange[300]! : Colors.orange[700]!,
              ),
              onTap: () => context.pushNamed('verification'),
            ),
          ],
        ],
      ),
      const SizedBox(height: 24), // Increased spacing for better UI
      _buildSectionLabel('Support', headerStyle),
      const SizedBox(height: 12),
      MenuCard(
        children: [
          MenuItem(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            subtitle: 'Get answers to common questions',
            onTap: () => context.pushNamed('help'),
          ),
          Divider(height: 1, color: dividerColor, indent: 55),
          MenuItem(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Help us improve the app',
            onTap: () => context.pushNamed('feedback'),
          ),
          Divider(height: 1, color: dividerColor, indent: 55),
          MenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version 1.0.0',
            onTap: () => context.pushNamed('about'),
          ),
        ],
      ),
    ],
  );
}

// Helper for section labels
Widget _buildSectionLabel(String text, TextStyle? style) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(text, style: style),
  );
}
