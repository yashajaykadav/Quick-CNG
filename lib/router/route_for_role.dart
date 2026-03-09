import 'package:flutter/material.dart';

import 'package:quickcng/models/enums.dart';
import 'package:quickcng/models/user.dart';
import 'package:quickcng/screens/admin/admin_dashboard_screen.dart';
import 'package:quickcng/screens/owner/owner_dashboard_screen.dart';
import 'package:quickcng/screens/auth/setup_profile_screen.dart';
import 'package:quickcng/screens/home/home_screen.dart';

Widget routeForRole(AppUser? profile) {
  if (profile == null) return const SetupProfileScreen();

  switch (profile.role) {
    case UserRole.admin:
      return const AdminDashboardScreen();
    case UserRole.owner:
      return const OwnerDashboardScreen();
    case UserRole.worker:
    case UserRole.user:
    case UserRole.guest:
      return const HomeScreen();
  }
}
