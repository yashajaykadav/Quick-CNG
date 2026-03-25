import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/providers/settings_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fixed provider name to 'settingsProvider'
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // This will be pure black in Dark Mode due to our main.dart config
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _buildHandle(theme),
          const SizedBox(height: 16),
          _buildHeader(context, theme),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Preferences', theme),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    theme: theme,
                    children: [
                      _buildSwitchItem(
                        context: context,
                        icon: Icons.notifications_outlined,
                        iconColor: Colors.blue,
                        title: 'Notifications',
                        value: settings.notificationsEnabled,
                        // 2. Fixed typo from 'toogle' to 'toggle'
                        onChanged: (val) => notifier.toggleNotifications(val),
                      ),
                      _buildDivider(theme),
                      _buildSwitchItem(
                        context: context,
                        icon: Icons.dark_mode_outlined,
                        iconColor: Colors.purple,
                        title: 'Dark Mode',
                        value: settings.isDarkMode,
                        onChanged: (val) => notifier.toggleDarkMode(val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) => Center(
    child: Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: theme.dividerColor.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context, ThemeData theme) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.brightness == Brightness.dark
              ? Colors.green[900]!.withAlpha(100)
              : Colors.green[50],
          child: Icon(
            Icons.settings,
            color: theme.brightness == Brightness.dark
                ? Colors.green[400]
                : Colors.green[700],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.grey[200],
          ),
        ),
      ],
    ),
  );

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.hintColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: theme.brightness == Brightness.dark
            ? Border.all(color: const Color(0xFF1E1E1E), width: 1)
            : null,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required MaterialColor iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? iconColor[900]?.withAlpha(80) : iconColor[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDark ? iconColor[300] : iconColor[700],
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.green,
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : theme.dividerColor.withAlpha(20),
      indent: 56,
      endIndent: 16,
    );
  }
}
