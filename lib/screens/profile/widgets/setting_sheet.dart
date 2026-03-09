import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Colors.green[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Settings Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Preferences'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    children: [
                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        iconColor: Colors.blue,
                        title: 'Notifications',
                        subtitle: 'Manage alerts and updates',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.language,
                        iconColor: Colors.orange,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSwitchItem(
                        icon: Icons.dark_mode_outlined,
                        iconColor: Colors.purple,
                        title: 'Dark Mode',
                        value: false,
                        onChanged: (val) {},
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required MaterialColor iconColor,
    required String title,
    String? subtitle,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor[700], size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            )
          : null,
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400])
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required MaterialColor iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor[700], size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.green[500],
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey[300],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 56,
      endIndent: 16,
    );
  }
}
