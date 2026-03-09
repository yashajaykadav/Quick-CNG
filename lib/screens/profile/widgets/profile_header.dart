import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/enums.dart';
import '../../../models/user.dart';

class ProfileHeader extends StatelessWidget {
  final AppUser? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false, // ✅ Important: Don't add bottom safe area
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ FIXED: Reduced top spacing
              const SizedBox(height: 20),

              // Avatar - Reduced size
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40, // ✅ Reduced from 50
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: ClipOval(
                        child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: user!.photoURL!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  _getRoleIcon(user?.role),
                                  size: 40,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _getRoleIcon(user?.role),
                                size: 40, // ✅ Reduced from 50
                                color: Colors.white,
                              ),
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
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16, // ✅ Reduced
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12), // ✅ Reduced from 16

              // Name
              Text(
                user?.name ?? 'Guest User',
                style: const TextStyle(
                  fontSize: 22, // ✅ Reduced from 24
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user?.email ?? 'Not signed in',
                style: TextStyle(
                  fontSize: 13, // ✅ Reduced from 14
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10), // ✅ Reduced from 12

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getRoleBadgeColor(user?.role),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(user?.role),
                      size: 14,
                      color: Colors.white,
                    ),
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
              ),

              const SizedBox(height: 16), // ✅ Bottom spacing
            ],
          ),
        ),
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

  Color _getRoleBadgeColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.owner:
        return Colors.amber[700]!;
      case UserRole.worker:
        return Colors.blue;
      case UserRole.user:
        return Colors.green[800]!;
      default:
        return Colors.grey[600]!;
    }
  }
}