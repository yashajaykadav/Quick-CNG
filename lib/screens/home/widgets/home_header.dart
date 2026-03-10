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
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1FAF5A), Color(0xFF0E8E46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER ROW
          Row(
            children: [
              /// LOGO
              Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(250),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(
                  'assets/images/logoCng.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              /// GREETING
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey(userProfile?.name ?? 'guest'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        userProfile?.name ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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

                  if (!isLoggedIn)
                    _HeaderIconButton(
                      icon: Icons.login,
                      tooltip: 'Login',
                      onTap: () => context.pushNamed('login'),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(250),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.green, size: 20),
            ),
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
    final color = _getRoleColor();

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
          backgroundColor: Colors.white.withAlpha(250),
          child: Icon(_getIcon(), color: Colors.green, size: 20),
        ),
      ),
    );
  }

  Color _getRoleColor() {
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

  void _onChanged(String value) {
    setState(() => hasText = value.isNotEmpty);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChanged(value);
    });
  }

  void _clear() {
    controller.clear();
    setState(() => hasText = false);
    widget.onChanged('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: "Search stations, areas...",
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasText
              ? IconButton(icon: const Icon(Icons.close), onPressed: _clear)
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
