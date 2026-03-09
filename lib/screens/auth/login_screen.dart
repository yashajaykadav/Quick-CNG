import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Icon(Icons.local_gas_station, size: 100, color: Colors.green[700]),
                const SizedBox(height: 24),

                // Title
                Text(
                  "QuickCNG",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to find nearby stations",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 60),

                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleGoogleLogin,
                    icon: isLoading
                        ? const SizedBox.shrink()
                        : Image.network('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg', height: 24, width: 24, errorBuilder: (c, e, s) => const Icon(Icons.login)),
                    label: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Continue with Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "By continuing, you agree to our Terms & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();

      if (result != null && mounted) {
        // Successful login: Navigation handled by AuthGate automatically,
        // but context.go('/home') provides a fallback.
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }
}