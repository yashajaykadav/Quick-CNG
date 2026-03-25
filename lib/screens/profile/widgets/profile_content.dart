import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/screens/profile/widgets/profile_header.dart';
import 'package:quickcng/screens/profile/widgets/quick_actions.dart';
import 'package:quickcng/screens/profile/widgets/setting_sheet.dart';
import '../../../models/user.dart';
import 'log_out.dart';
import 'menu_section.dart';

class ProfileContent extends ConsumerWidget {
  final AppUser? user;

  const ProfileContent({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final appBarColor = isDark ? Colors.black : Colors.green[700];
    final iconColor = Colors.white;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: appBarColor,
          flexibleSpace: FlexibleSpaceBar(
            background: ProfileHeader(user: user),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: iconColor),
              onPressed: () => _showSettingsSheet(context, ref),
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              buildQuickActions(context, user),
              const SizedBox(height: 24),
              buildMenuSection(context, user),
              const SizedBox(height: 24),
              LogoutButton(),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SettingsSheet(),
    );
  }
}
