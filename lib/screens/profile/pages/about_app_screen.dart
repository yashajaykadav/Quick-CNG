import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ Adaptive Background (Pure Black in Dark Mode)
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About QuickCNG'),
        // ✅ Pulls from your main.dart AppBarTheme
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // App Logo
            _buildLogo(),
            const SizedBox(height: 24),

            // App Name & Version
            Text(
              'QuickCNG',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildVersionBadge(isDark),
            const SizedBox(height: 32),

            // App Description
            Text(
              "Your reliable companion for finding active CNG stations in real-time. We rely on the community and verified station owners to keep traffic and availability data completely accurate.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),

            // Developer Info Card
            _buildDevCard(theme, isDark),
            const SizedBox(height: 40),

            Text(
              '© ${DateTime.now().year} QuickCNG. All rights reserved.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[700],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(40),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.local_gas_station, color: Colors.white, size: 70),
    );
  }

  Widget _buildVersionBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue[900]?.withAlpha(40) : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.blue[800]!, width: 1) : null,
      ),
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          color: isDark ? Colors.blue[200] : Colors.blue[800],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDevCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ✅ Uses Card Color (0xFF121212) for Dark Mode
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white.withAlpha(15), width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Text(
            'DEVELOPED BY',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Yash Ajay Kadav',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crafted specifically to make your driving experience frictionless.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor.withAlpha(15)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.language, Colors.blue, isDark),
              const SizedBox(width: 24),
              _buildSocialButton(Icons.mail_outline, Colors.red, isDark),
              const SizedBox(width: 24),
              _buildSocialButton(Icons.group_outlined, Colors.purple, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(40) : color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: isDark ? color.withAlpha(220) : color, size: 24),
    );
  }
}
