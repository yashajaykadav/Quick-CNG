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
    return CustomScrollView(
      slivers: [
        // ✅ FIXED: Increased expandedHeight
        SliverAppBar(
          expandedHeight: 250, // Increased from 280
          pinned: true,
          backgroundColor: Colors.green[700],
          flexibleSpace: FlexibleSpaceBar(
            background: ProfileHeader(user: user),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => _showSettingsSheet(context, ref),
            ),
          ],
        ),

        // Content
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