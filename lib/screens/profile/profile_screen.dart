import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/providers/user_provider.dart';
import 'package:quickcng/screens/error/error_screen.dart';
import 'package:quickcng/screens/profile/widgets/profile_content.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: userProfileAsync.when(
        data: (user) => ProfileContent(user: user),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
        error: (err, _) => ErrorScreen(error: err.toString(), path: '/',),
      ),
    );
  }
}