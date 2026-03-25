import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget appBar(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // ✅ AMOLED Adaptive Gradient
  final gradientColors = isDark
      ? [Colors.black, const Color(0xFF121212)]
      : [Colors.green[900]!, Colors.green[700]!];

  return SliverAppBar(
    expandedHeight: 180,
    pinned: true,
    // Set to black in dark mode to match the status bar and scaffold
    backgroundColor: isDark ? Colors.black : Colors.green[800],
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => context.go('/home'),
    ),
    flexibleSpace: FlexibleSpaceBar(
      titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
      title: const Text(
        'Admin Control Panel',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          // ✅ Bottom border to define the edge on pure black backgrounds
          border: isDark
              ? Border(
                  bottom: BorderSide(
                    color: Colors.white.withAlpha(20),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ghost Icon (Lowered alpha for OLED to prevent blooming)
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.admin_panel_settings,
                size: 200,
                color: Colors.white.withAlpha(isDark ? 15 : 25),
              ),
            ),

            // Super Admin Badge
            Positioned(
              left: 20,
              top: 75, // Adjusted for safe area
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.white, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
