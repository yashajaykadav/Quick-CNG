import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/screens/profile/widgets/quick_action_card.dart';
import '../../../models/enums.dart';
import '../../../models/user.dart';

Widget buildQuickActions(BuildContext context, AppUser? user) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final isStaff = user?.isStationStaff ?? false;
  final isAdmin = user?.role == UserRole.admin;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quick Actions',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: isStaff || isAdmin
                ? QuickActionCard(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    color: Colors.orange,
                    onTap: () =>
                        context.pushNamed(isAdmin ? 'admin' : 'dashboard'),
                  )
                : QuickActionCard(
                    icon: Icons.verified_user,
                    label: 'Get Verified',
                    color: Colors.purple,
                    onTap: () => context.pushNamed('verification'),
                  ),
          ),
        ],
      ),
    ],
  );
}
