import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/providers/auth_provider.dart';
import 'package:quickcng/providers/user_provider.dart';

import '../../router/route_for_role.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final userProfileAsync = ref.watch(userProfileProvider);

        return userProfileAsync.when(
          data: (profile) => routeForRole(profile),
          loading: () => _buildLoadingScreen('Loading Profile...'),
          error: (error, stack) => _buildErrorScreen(
            context,
            ref,
            'Profile Error',
            error.toString(),
          ),
        );
      },
      loading: () => _buildLoadingScreen('Signing you in...'),
      error: (error, stack) => _buildErrorScreen(
        context,
        ref,
        'Authentication Failed',
        error.toString(),
      ),
    );
  }

  /// Loading screen widget
  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Error screen widget
  Widget _buildErrorScreen(
      BuildContext context,
      WidgetRef ref,
      String title,
      String error,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(authStateProvider);
                      ref.invalidate(userProfileProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to home as guest
                     context.go('/home');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}