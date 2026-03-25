import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/enums.dart';
import '../../../models/user.dart';

class ProfileHeader extends StatelessWidget {
  final AppUser? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ AMOLED Gradient: Pure black to deep grey
    final gradientColors = isDark
        ? [Colors.black, const Color(0xFF121212)]
        : [Colors.green[700]!, Colors.green[500]!];

    final textColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildAvatar(textColor),
              const SizedBox(height: 12),

              // Name
              Text(
                user?.name ?? 'Guest User',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user?.email ?? 'Not signed in',
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withAlpha(
                    180,
                  ), // Slightly more visible than 80
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Role Badge
              _buildRoleBadge(isDark),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color textColor) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: textColor.withAlpha(50), width: 2),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: textColor.withAlpha(30),
            child: ClipOval(
              child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user!.photoURL!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                      errorWidget: (context, url, error) => Icon(
                        _getRoleIcon(user?.role),
                        size: 40,
                        color: textColor,
                      ),
                    )
                  : Icon(_getRoleIcon(user?.role), size: 40, color: textColor),
            ),
          ),
        ),
        if (user?.isVerified ?? false)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildRoleBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleBadgeColor(user?.role, isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRoleIcon(user?.role), size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            user?.role.displayName ?? 'Guest',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.owner:
        return Icons.store;
      case UserRole.worker:
        return Icons.badge;
      case UserRole.user:
        return Icons.directions_car;
      default:
        return Icons.person;
    }
  }

  Color _getRoleBadgeColor(UserRole? role, bool isDark) {
    switch (role) {
      case UserRole.admin:
        return isDark ? Colors.red[700]! : Colors.red;
      case UserRole.owner:
        return isDark ? Colors.amber[800]! : Colors.amber[700]!;
      case UserRole.worker:
        return isDark ? Colors.blue[700]! : Colors.blue;
      case UserRole.user:
        return isDark ? Colors.green[700]! : Colors.green[800]!;
      default:
        return isDark ? Colors.grey[800]! : Colors.grey[600]!;
    }
  }
}
