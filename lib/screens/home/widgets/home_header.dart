import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/models/enums.dart';
import '../../../models/user.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/auth_provider.dart';

class HomeHeader extends ConsumerWidget {
  final ValueChanged<String> onSearch;

  const HomeHeader({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProfileProvider);
    ref.watch(isLoggedInProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ AMOLED Adaptive Gradient
    final gradientColors = isDark
        ? [Colors.black, const Color(0xFF121212)]
        : [const Color(0xFF1FAF5A), const Color(0xFF0E8E46)];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        // Subtle border for AMOLED definition
        border: isDark
            ? Border(bottom: BorderSide(color: Colors.white.withAlpha(20)))
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /// LOGO
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/logoCng.png',
                    width: 42,
                    height: 42,
                  ),
                ),

                const SizedBox(width: 12),

                /// GREETING
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? theme.hintColor : Colors.white70,
                        ),
                      ),
                      Text(
                        userProfile?.name ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // Keep white for contrast on gradients
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                /// ACTIONS
                Row(
                  children: [
                    if (userProfile?.isStationStaff ?? false)
                      _HeaderIconButton(
                        icon: Icons.dashboard,
                        tooltip: 'Dashboard',
                        onTap: () => context.pushNamed('dashboard'),
                      ),
                    if (userProfile?.role == UserRole.admin)
                      _HeaderIconButton(
                        icon: Icons.admin_panel_settings,
                        tooltip: 'Admin',
                        onTap: () => context.pushNamed('admin'),
                      ),
                    _ProfileButton(userProfile: userProfile),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// SEARCH
            _SearchField(onChanged: onSearch),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, color: isDark ? Colors.green[400] : Colors.green[700]),
        style: IconButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final AppUser? userProfile;

  const _ProfileButton({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getRoleColor(isDark);

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => context.pushNamed('profile'),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          child: Icon(_getIcon(), color: Colors.green, size: 20),
        ),
      ),
    );
  }

  Color _getRoleColor(bool isDark) {
    if (userProfile == null) return Colors.white.withAlpha(80);
    switch (userProfile!.role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.owner:
        return Colors.amber;
      case UserRole.worker:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  IconData _getIcon() {
    if (userProfile == null) return Icons.person_outline;
    switch (userProfile!.role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.owner:
        return Icons.store;
      case UserRole.worker:
        return Icons.badge;
      default:
        return Icons.person;
    }
  }
}

class _SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  Timer? _debounce;
  final controller = TextEditingController();
  bool hasText = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // ✅ Uses adaptive card color
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: Colors.white.withAlpha(20)) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: theme.colorScheme.onSurface),
        onChanged: (value) {
          setState(() => hasText = value.isNotEmpty);
          _debounce?.cancel();
          _debounce = Timer(
            const Duration(milliseconds: 400),
            () => widget.onChanged(value),
          );
        },
        decoration: InputDecoration(
          hintText: "Search stations, areas...",
          hintStyle: TextStyle(color: theme.hintColor),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.green[400] : Colors.green[700],
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    setState(() => hasText = false);
                    widget.onChanged('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }
}
