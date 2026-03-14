import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/screens/profile/widgets/status_badge.dart';
import '../../../models/enums.dart';
import '../../../models/user.dart';
import 'menu_card.dart';
import 'menu_item.dart';

Widget buildMenuSection(BuildContext context, AppUser? user) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Account',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      MenuCard(
        children: [
          MenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () => context.pushNamed('edit-profile'),
          ),
          const Divider(height: 1),
          MenuItem(
            icon: Icons.assignment_outlined,
            title: 'My Reports',
            subtitle: 'View your submitted reports',
            onTap: () => context.pushNamed('my-reports'),
          ),
          if (user?.role == UserRole.user || user?.role == UserRole.guest) ...[
            const Divider(height: 1),
            MenuItem(
              icon: Icons.verified_outlined,
              title: 'Verification Status',
              subtitle: 'Check your verification request',
              trailing: StatusBadge(text: 'Not Verified', color: Colors.orange),
              onTap: () => context.pushNamed('verification'),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Support',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      MenuCard(
        children: [
          MenuItem(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            subtitle: 'Get answers to common questions',
            onTap: () => context.pushNamed('help'),
          ),
          const Divider(height: 1),
          MenuItem(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Help us improve the app',
            onTap: () => context.pushNamed('feedback'),
          ),
          const Divider(height: 1),
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
